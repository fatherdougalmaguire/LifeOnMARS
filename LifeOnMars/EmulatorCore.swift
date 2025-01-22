//
//  EmulatorCore.swift
//  LifeOnMARS
//
//  Created by Antonio Sanchez-Rivas on 10/2/2024.
//  Version 0.1 3/3/2024
//  Version 0.2 10/3/2024
//
// MARS (Memory Array Redcode Simulator) emulator core in Swift

import Foundation
import SwiftUI

class EmulatorCore : ObservableObject {
    
    enum RedCodeInstructionType {
        case DAT   //   DAT             B   Initialize location to value B.
        case MOV   //   MOV     A       B   Move A into location B.
        case ADD   //   ADD     A       B   Add  operand  A  to   contents  of location  B  and  store  result in location B.
        case SUB   //   SUB     A       B   Subtract operand  A  from contents of location  B and store result in location B.
        case MUL   // multiply (multiplies one number with another)
        case DIV   // divide (divides one number with another)
        case MOD   // modulus (divides one number with another and gives the remainder)
        case JMP   //   JMP             B   Jump to location B.
        case JMZ   //   JMZ     A       B   If operand A is  0, jump  to location  B;  otherwise  continue with next instruction.
        case JMN   // jump if not zero (tests a number and jumps if it isn't 0)
        case DJZ   //   DJZ     A       B   Decrement contents  of  location A by 1.  If location  A now holds 0, jump  to   location  B;  otherwise continue with next instruction.
        case DJN   // decrement and jump if not zero (decrements a number by one, and jumps unless the result is 0)
        case CMP   //   CMP     A       B   Compare operand  A with operand B. If they  are not  equal, skip next instruction;   otherwise  continue with next instruction.
        case SEQ   // skip if equal (compares two instructions, and skips the next instruction if they are equal)
        case SNE   // skip if not equal (compares two instructions, and skips the next instruction if they aren't equal)
        case SLT   // skip if lower than (compares two values, and skips the next instruction if the first is lower than the second)
        case LDP   // load from p-space (loads a number from private storage space)
        case STP   // save to p-space (saves a number to private storage space)
        case NOP   // no operation (does nothing)
        case SPL  //  SPL   A       The spl instruction spawns a new process for the current warrior at the address specified by the A operand.
    }
    
    enum RedCodeModifier {
        case DotA   //      .a    A operand    A operand
        case DotB   //      .b    B operand    B operand
        case DotAB  //      .ab    A operand    B operand
        case DotBA  //      .ba    B operand    A operand
        case DotF   //      .f    A and B operands    A and B operands
        case DotX   //      .x    A and B operands    B and A operands
        case DotI   //      .i    Whole instruction    Whole instruction
    }
    
    enum RedCodeAddressMode {
        case Immediate              // #
        case Direct                 // $ or nothing
        case AIndirect              // *
        case BIndirect              // @
        case APreDecrementIndirect  // {
        case APostIncrementIndirect // }
        case BPreDecrementIndirect  // <
        case BPostIncrementIndirect // >
    }
    
    struct RedCodeInstruction {
        
        var OpCode:RedCodeInstructionType = RedCodeInstructionType.DAT
        var Modifier : RedCodeModifier = RedCodeModifier.DotF
        var AfieldAddressMode:RedCodeAddressMode = RedCodeAddressMode.Immediate
        var AfieldAddress:Int = 0
        var BfieldAddressMode:RedCodeAddressMode = RedCodeAddressMode.Immediate
        var BfieldAddress:Int = 0
        var InstructionColour:Color = .black
        
    }
    
    struct Warrior {
        
        var WarriorProgramID : Int
        var WarriorProgramTitle : String
        var WarriorCode : Array<RedCodeInstruction>
        var WarriorStartCoreAddress : Int
        var WarriorColour : Color
    }
    
    struct WarriorQueue {
        
        var WarriorProgramID : Int
        var WarriorProcessID : Int
        var WarriorProgramStatus : Bool
        var WarriorProcessStatus : Bool
        var WarriorCurrentCoreAddress : Int
        
    }
    
    var CoreCycles: Int = 1000
    var CoreRunning = false
    var CoreSize: Int = 8000
    var CoreSizeInRows: Int
    var CoreSizeInCols: Int
    var CoreCellSize: Double
    var CoreDrawSize : Int
    var CoreUpdateFreq : Double = 0.1
    
    var CoreCurrentProcessIndex : Int = 0
    
    var Warriors : Array<Warrior>
    var CoreWarriorQueue : Array<WarriorQueue>
    
    @Published var Core : Array<RedCodeInstruction>
    @Published var CoreBuffer : Array<Float>
    
    init() {
        self.Warriors = []
        self.CoreWarriorQueue = []
        if self.CoreSize <= 100 {
            self.CoreSizeInRows = 4
            self.CoreSizeInCols = 25
            self.CoreCellSize = 15
            CoreDrawSize = self.CoreSizeInRows*self.CoreSizeInCols
        }
        else if self.CoreSize <= 1000
        {
            self.CoreSizeInRows = 20
            self.CoreSizeInCols = 50
            self.CoreCellSize = 10
            CoreDrawSize = self.CoreSizeInRows*self.CoreSizeInCols
        }
        else
        {
            self.CoreSizeInRows = 70
            self.CoreSizeInCols = 120
            self.CoreCellSize = 10
            CoreDrawSize = self.CoreSizeInRows*self.CoreSizeInCols
        }
        self.Core = Array<RedCodeInstruction>(repeating: RedCodeInstruction(),count:CoreSize)
        self.CoreBuffer = Array<Float>(repeating: 0.0,count:CoreSize)
        for MyIndex in 0..<CoreSize {
            self.Core[MyIndex].InstructionColour = .black
        }
        
        self.CoreUpdateFreq = 0.1
    }
    
    func FormatCoreOutput(_ PassedCurrentAddress : Int) -> String {
        
        var CurrentRedCodeInstruction : RedCodeInstruction
        var FormattedString : String = ""
        
        CurrentRedCodeInstruction = Core[PassedCurrentAddress]
        
        FormattedString = String(format: "%06d", PassedCurrentAddress)+"    "
        
        switch CurrentRedCodeInstruction.OpCode {
        case .DAT:
            FormattedString = FormattedString+"DAT"
        case .MOV:
            FormattedString = FormattedString+"MOV"
        case .ADD:
            FormattedString = FormattedString+"ADD"
        case .SUB:
            FormattedString = FormattedString+"SUB"
        case .MUL:
            FormattedString = FormattedString+"MUL"
        case .DIV:
            FormattedString = FormattedString+"DIV"
        case .MOD:
            FormattedString = FormattedString+"MOD"
        case .JMP:
            FormattedString = FormattedString+"JMP"
        case .JMZ:
            FormattedString = FormattedString+"JMZ"
        case .JMN:
            FormattedString = FormattedString+"JMN"
        case .DJZ:
            FormattedString = FormattedString+"DJZ"
        case .DJN:
            FormattedString = FormattedString+"DJN"
        case .CMP:
            FormattedString = FormattedString+"CMP"
        case .SEQ:
            FormattedString = FormattedString+"SEQ"
        case .SNE:
            FormattedString = FormattedString+"SNE"
        case .SLT:
            FormattedString = FormattedString+"SLT"
        case .LDP:
            FormattedString = FormattedString+"LDP"
        case .STP:
            FormattedString = FormattedString+"STP"
        case .NOP:
            FormattedString = FormattedString+"NOP"
        case .SPL:
            FormattedString = FormattedString+"SPL"
        }
        
        switch CurrentRedCodeInstruction.Modifier {
        case .DotA:
            FormattedString = FormattedString+".A"
        case .DotB:
            FormattedString = FormattedString+".B"
        case .DotAB:
            FormattedString = FormattedString+".AB"
        case .DotBA:
            FormattedString = FormattedString+".BA"
        case .DotF:
            FormattedString = FormattedString+".F"
        case .DotX:
            FormattedString = FormattedString+".X"
        case .DotI:
            FormattedString = FormattedString+".I"
        }
        
        print(FormattedString.count)
        
        if FormattedString.count == 15 {
            FormattedString = FormattedString + " "
        }
        
        FormattedString = FormattedString + "    "
        
        switch CurrentRedCodeInstruction.AfieldAddressMode {
        case .Immediate:
            FormattedString = FormattedString+"#"
        case .Direct:
            FormattedString = FormattedString+"$"
        case .AIndirect:
            FormattedString = FormattedString+"*"
        case .BIndirect:
            FormattedString = FormattedString+"@"
        case .APreDecrementIndirect:
            FormattedString = FormattedString+"{"
        case .APostIncrementIndirect:
            FormattedString = FormattedString+"}"
        case .BPreDecrementIndirect :
            FormattedString = FormattedString+"<"
        case .BPostIncrementIndirect:
            FormattedString = FormattedString+">"
        }
        
        FormattedString = FormattedString+String(format: "%06d", CurrentRedCodeInstruction.AfieldAddress)+","
        
        switch CurrentRedCodeInstruction.BfieldAddressMode {
        case .Immediate:
            FormattedString = FormattedString+"#"
        case .Direct:
            FormattedString = FormattedString+"$"
        case .AIndirect:
            FormattedString = FormattedString+"*"
        case .BIndirect:
            FormattedString = FormattedString+"@"
        case .APreDecrementIndirect:
            FormattedString = FormattedString+"{"
        case .APostIncrementIndirect:
            FormattedString = FormattedString+"}"
        case .BPreDecrementIndirect :
            FormattedString = FormattedString+"<"
        case .BPostIncrementIndirect:
            FormattedString = FormattedString+">"
        }
        
        FormattedString = FormattedString+String(format: "%06d", CurrentRedCodeInstruction.BfieldAddress)
        
        return FormattedString
    }
    
    func ParseWarriorCode ( _ RedCodeInput : String)
    
    //    0187         assembly_file:
    //    0188                 list
    //    0189         list:
    //    0190                 line | line list
    //    0191         line:
    //    0192                 comment | instruction
    //    0193         comment:
    //    0194                 ; v* EOL | EOL
    //    0195         instruction:
    //    0196                 label_list operation mode field comment |
    //    0197                 label_list operation mode expr , mode expr comment
    //    0198         label_list:
    //    0199                 label | label label_list | label newline label_list | e
    //    0200         label:
    //    0201                 alpha alphanumeral*
    //    0202         operation:
    //    0203                 opcode | opcode.modifier
    //    0204         opcode:
    //    0205                 DAT | MOV | ADD | SUB | MUL | DIV | MOD |
    //    0206                 JMP | JMZ | JMN | DJN | CMP | SLT | SPL |
    //    0207                 ORG | EQU | END
    //    0208         modifier:
    //    0209                 A | B | AB | BA | F | X | I
    //    0210         mode:
    //    0211                 # | $ | @ | < | > | e
    //    0212         expr:
    //    0213                 term |
    //    0214                 term + expr | term - expr |
    //    0215                 term * expr | term / expr |
    //    0216                 term % expr
    //    0217         term:
    //    0218                 label | number | (expression)
    //    0219         number:
    //    0220                 whole_number | signed_integer
    //    0221         signed_integer:
    //    0222                 +whole_number | -whole_number
    //    0223         whole_number:
    //    0224                 numeral+
    //    0225         alpha:
    //    0226                 A-Z | a-z | _
    //    0227         numeral:
    //    0228                 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
    //    0229         alphanumeral:
    //    0230                 alpha | numeral
    //    0231         v:
    //    0232                 ^EOL
    //    0233         EOL:
    //    0234                 newline | EOF
    //    0235         newline:
    //    0236                 LF | CR | LF CR | CR LF
    //    0237         e:
    
    {
        print(RedCodeInput.trimmingCharacters(in: .whitespaces))
    }
    
    func LoadCore() {
        
        var TempRedCodeInstruction : Array<RedCodeInstruction> = []
        var TempCoreStartAddress : Int
        var WarriorCollision = Array<Bool>(repeating: false,count:CoreSize)
        var WarriorCollisionFlag : Bool
        var WarriorCode : String
        
        WarriorCode = "      MOV 0, 1"
        
        ParseWarriorCode(WarriorCode)
        
        WarriorCode = """
        //        ADD #4, 3        ; execution begins here
        //        MOV 2, @2
        //        JMP -2
        //        DAT #0, #0  
        """
        
        ParseWarriorCode(WarriorCode)
        
        if Warriors.count == 0 {
            TempCoreStartAddress = Int.random(in: 0...CoreSize-1)
            // TempCoreStartAddress = 7800
            
            //      MOV 0, 1
            
            TempRedCodeInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.MOV,Modifier : RedCodeModifier.DotI,AfieldAddressMode : RedCodeAddressMode.Direct,AfieldAddress:0,BfieldAddressMode : RedCodeAddressMode.Direct,BfieldAddress : 1,InstructionColour : .green))
            
            Warriors.append(Warrior(WarriorProgramID:0,WarriorProgramTitle:"Barry the IMP",WarriorCode:TempRedCodeInstruction,WarriorStartCoreAddress:TempCoreStartAddress,WarriorColour: .green))
            
            CoreBuffer[TempCoreStartAddress] = 2
            CoreBuffer[TempCoreStartAddress+1] = 2
            CoreBuffer[TempCoreStartAddress+2] = 2
            CoreBuffer[TempCoreStartAddress+3] = 2
            
            for WarriorIndex in 0...Warriors[0].WarriorCode.count-1 {
                WarriorCollision[CoreWrapAddress(TempCoreStartAddress,WarriorIndex,CoreSize)] = true
            }
            
            CoreWarriorQueue.append(WarriorQueue(WarriorProgramID: 0, WarriorProcessID: 0, WarriorProgramStatus: true, WarriorProcessStatus: true,WarriorCurrentCoreAddress : TempCoreStartAddress))
            Core[TempCoreStartAddress] = TempRedCodeInstruction[0]
            
            TempCoreStartAddress = Int.random(in: 0...CoreSize-1)
            //TempCoreStartAddress = 7900
            
            TempRedCodeInstruction = []
            
            //        ADD #4, 3        ; execution begins here
            //        MOV 2, @2
            //        JMP -2
            //        DAT #0, #0
            
            TempRedCodeInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.ADD,Modifier : RedCodeModifier.DotAB,AfieldAddressMode : RedCodeAddressMode.Immediate,AfieldAddress:4,BfieldAddressMode : RedCodeAddressMode.Direct,BfieldAddress : 3,InstructionColour : .red))
            TempRedCodeInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.MOV,Modifier : RedCodeModifier.DotI,AfieldAddressMode : RedCodeAddressMode.Direct,AfieldAddress:2,BfieldAddressMode : RedCodeAddressMode.BIndirect,BfieldAddress : 2,InstructionColour : .red))
            TempRedCodeInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.JMP,Modifier : RedCodeModifier.DotB,AfieldAddressMode : RedCodeAddressMode.Direct,AfieldAddress:-2,BfieldAddressMode : RedCodeAddressMode.Direct,BfieldAddress : 0,InstructionColour : .red))
            TempRedCodeInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.DAT,Modifier : RedCodeModifier.DotI,AfieldAddressMode : RedCodeAddressMode.Immediate,AfieldAddress:0,BfieldAddressMode : RedCodeAddressMode.Immediate,BfieldAddress : 0,InstructionColour : .red))
            
            Warriors.append(Warrior(WarriorProgramID:1,WarriorProgramTitle:"Kevin the Dwarf",WarriorCode:TempRedCodeInstruction,WarriorStartCoreAddress:TempCoreStartAddress,WarriorColour: .red))
            
            CoreBuffer[TempCoreStartAddress] = 1
            CoreBuffer[TempCoreStartAddress+1] = 1
            CoreBuffer[TempCoreStartAddress+2] = 1
            CoreBuffer[TempCoreStartAddress+3] = 1
            
            repeat
            {
                WarriorCollisionFlag = false
                for WarriorIndex in 0...TempRedCodeInstruction.count
                {
                    if WarriorCollision[CoreWrapAddress(TempCoreStartAddress,WarriorIndex,CoreSize)]
                    {
                        WarriorCollisionFlag = true
                    }
                }
                if WarriorCollisionFlag
                {
                    TempCoreStartAddress = Int.random(in: 0...CoreSize)
                }
            }
            while WarriorCollisionFlag
                    
                    CoreWarriorQueue.append(WarriorQueue(WarriorProgramID: 1, WarriorProcessID: 0, WarriorProgramStatus: true, WarriorProcessStatus: true,WarriorCurrentCoreAddress : TempCoreStartAddress))
                    
                    Core[TempCoreStartAddress] = TempRedCodeInstruction[0]
                    Core[CoreWrapAddress(TempCoreStartAddress,1,CoreSize)] = TempRedCodeInstruction[1]
                    Core[CoreWrapAddress(TempCoreStartAddress,2,CoreSize)] = TempRedCodeInstruction[2]
                    Core[CoreWrapAddress(TempCoreStartAddress,3,CoreSize)] = TempRedCodeInstruction[3]
                    
                    for WarriorIndex in 0...Warriors[1].WarriorCode.count-1
            {
                WarriorCollision[CoreWrapAddress(TempCoreStartAddress,WarriorIndex,CoreSize)] = true
            }
        }
    }
    
    func ResetCore() {
        Core = Array<RedCodeInstruction>(repeating: RedCodeInstruction(),count:CoreSize)
        for MyIndex in 0..<CoreSize
        {
            Core[MyIndex].InstructionColour = .black
            CoreBuffer[MyIndex] = 0
        }
        Warriors = []
        CoreWarriorQueue = []
        CoreCurrentProcessIndex = 0
    }
    
    func CoreRunMode(_ PassedRunMode : Bool ) {
        
        CoreRunning = PassedRunMode
        
    }
    
    func SetCoreCycles(_ PassedRunCycles : Int ) {
        
        CoreCycles = PassedRunCycles
        
    }
    
    func CoreWrapAddress ( _ PassedCurrentAddress : Int, _ PassedAddressIncrement : Int, _ PassedCoreSize : Int ) -> Int {
        
        if PassedAddressIncrement < 0 {
            
            return (PassedCurrentAddress+PassedCoreSize-abs(PassedAddressIncrement)) % PassedCoreSize
        }
        else
        {
            return (PassedCurrentAddress+PassedAddressIncrement) % PassedCoreSize
        }
    }
    
    func CoreStepExecute()  {
        
        func CoreEvaluateOperand ( _ PassedAddressMode : RedCodeAddressMode, _ PassedAddress : Int ) -> RedCodeRegister  {
            
            var EvalAddress : Int
            var IntermediateEvalAddress : Int
            var TempRedCodeRegister : RedCodeRegister = RedCodeRegister.init()
            
            TempRedCodeRegister.RegisterInstruction = RedCodeInstruction.init()
            TempRedCodeRegister.RegisterAddress = 0
            
            switch PassedAddressMode
            {
            case .Immediate:
                print("Immediate")
                EvalAddress = CoreCurrentAddress
            case .Direct:
                print("Direct")
                EvalAddress = CoreWrapAddress(CoreCurrentAddress,PassedAddress,CoreSize)
            case .AIndirect:
                print("AIndirect")
                IntermediateEvalAddress = Core[CoreWrapAddress(CoreCurrentAddress,PassedAddress,CoreSize)].AfieldAddress
                EvalAddress = CoreWrapAddress(CoreCurrentAddress,PassedAddress+IntermediateEvalAddress,CoreSize)
            case .BIndirect:
                print("BIndirect")
                IntermediateEvalAddress = Core[CoreWrapAddress(CoreCurrentAddress,PassedAddress,CoreSize)].BfieldAddress
                EvalAddress = CoreWrapAddress(CoreCurrentAddress,PassedAddress+IntermediateEvalAddress,CoreSize)
            case .APreDecrementIndirect:
                print("APreDecrementIndirect")
                IntermediateEvalAddress = Core[CoreWrapAddress(CoreCurrentAddress,PassedAddress,CoreSize)].AfieldAddress
                EvalAddress = CoreWrapAddress(CoreCurrentAddress,PassedAddress-IntermediateEvalAddress,CoreSize)
            case .APostIncrementIndirect:
                print("APostDecrementIndirect")
                IntermediateEvalAddress = Core[CoreWrapAddress(CoreCurrentAddress,PassedAddress,CoreSize)].AfieldAddress
                EvalAddress = CoreWrapAddress(CoreCurrentAddress,PassedAddress+IntermediateEvalAddress,CoreSize)
            case .BPreDecrementIndirect :
                print("BPreDecrementIndirect")
                IntermediateEvalAddress = Core[CoreWrapAddress(CoreCurrentAddress,PassedAddress,CoreSize)].BfieldAddress
                EvalAddress = CoreWrapAddress(CoreCurrentAddress,PassedAddress-IntermediateEvalAddress,CoreSize)
            case .BPostIncrementIndirect:
                print("BPostDecrementIndirect")
                IntermediateEvalAddress = Core[CoreWrapAddress(CoreCurrentAddress,PassedAddress,CoreSize)].BfieldAddress
                EvalAddress = CoreWrapAddress(CoreCurrentAddress,PassedAddress+IntermediateEvalAddress,CoreSize)
            }
            
            TempRedCodeRegister.RegisterInstruction = Core[EvalAddress]
            
            if Core[EvalAddress].InstructionColour == .red
            { CoreBuffer[EvalAddress] = 1}
            if Core[EvalAddress].InstructionColour == .green
            { CoreBuffer[EvalAddress] = 2}
            TempRedCodeRegister.RegisterAddress = EvalAddress
            
            return TempRedCodeRegister
        }
        
        //var date = Date()
        //var milliseconds = String(Int(date.timeIntervalSince1970 * 1000))
        //print("S"+milliseconds)
        
        struct RedCodeRegister {
            
            var RegisterAddress : Int = 0
            var RegisterInstruction:RedCodeInstruction = RedCodeInstruction.init()
            
        }
        
        var CoreCurrentAddress: Int = 0
        var JumpAddress : Int = 0
        var JumpFlag : Bool = false
        var InstructionRegister:RedCodeRegister = RedCodeRegister.init()
        var SourceRegister:RedCodeRegister = RedCodeRegister.init()
        var DestinationRegister:RedCodeRegister = RedCodeRegister.init()
        
        if CoreRunning
        {
            
            CoreCurrentAddress = CoreWarriorQueue[CoreCurrentProcessIndex].WarriorCurrentCoreAddress
            
            print(CoreCurrentAddress)
            print(Warriors[CoreCurrentProcessIndex].WarriorProgramTitle)
            
            InstructionRegister.RegisterAddress = CoreCurrentAddress
            InstructionRegister.RegisterInstruction = Core[CoreCurrentAddress]
            
            SourceRegister = CoreEvaluateOperand(InstructionRegister.RegisterInstruction.AfieldAddressMode,InstructionRegister.RegisterInstruction.AfieldAddress)
            DestinationRegister = CoreEvaluateOperand(InstructionRegister.RegisterInstruction.BfieldAddressMode,InstructionRegister.RegisterInstruction.BfieldAddress)
            
            switch InstructionRegister.RegisterInstruction.OpCode {
            case .DAT:
                print("Bang! Warrior "+String(CoreWarriorQueue[CoreCurrentProcessIndex].WarriorProgramID)+" is dead")
                CoreWarriorQueue[CoreCurrentProcessIndex].WarriorProgramStatus = false
            case .MOV:
                print("MOV")
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA:
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].AfieldAddressMode = SourceRegister.RegisterInstruction.AfieldAddressMode
                case .DotB:
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = SourceRegister.RegisterInstruction.BfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddressMode = SourceRegister.RegisterInstruction.BfieldAddressMode
                case .DotAB:
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddressMode = SourceRegister.RegisterInstruction.AfieldAddressMode
                case .DotBA:
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = SourceRegister.RegisterInstruction.BfieldAddress
                    Core[DestinationRegister.RegisterAddress].AfieldAddressMode = SourceRegister.RegisterInstruction.BfieldAddressMode
                case .DotF:
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].AfieldAddressMode = SourceRegister.RegisterInstruction.AfieldAddressMode
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = SourceRegister.RegisterInstruction.BfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddressMode = SourceRegister.RegisterInstruction.BfieldAddressMode
                case .DotX:
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddressMode = SourceRegister.RegisterInstruction.AfieldAddressMode
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = SourceRegister.RegisterInstruction.BfieldAddress
                    Core[DestinationRegister.RegisterAddress].AfieldAddressMode = SourceRegister.RegisterInstruction.BfieldAddressMode
                case .DotI:
                    Core[DestinationRegister.RegisterAddress] = SourceRegister.RegisterInstruction
                }
            case .ADD:
                print("ADD")
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA: //  A operand  =>  A operand
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = SourceRegister.RegisterInstruction.AfieldAddress+DestinationRegister.RegisterInstruction.AfieldAddress
                case .DotB: //  B operand  =>  B operand
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = SourceRegister.RegisterInstruction.BfieldAddress+DestinationRegister.RegisterInstruction.BfieldAddress
                case .DotAB: //  A operand  =>  B operand
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = SourceRegister.RegisterInstruction.AfieldAddress+DestinationRegister.RegisterInstruction.BfieldAddress
                case .DotBA: //  B operand  =>  A operand
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = SourceRegister.RegisterInstruction.BfieldAddress+DestinationRegister.RegisterInstruction.AfieldAddress
                case .DotF: //  A and B operands  =>  A and B operands
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = SourceRegister.RegisterInstruction.AfieldAddress+DestinationRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = SourceRegister.RegisterInstruction.BfieldAddress+DestinationRegister.RegisterInstruction.BfieldAddress
                case .DotX: //  A and B operands  =>  B and A operands
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = SourceRegister.RegisterInstruction.AfieldAddress+DestinationRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = SourceRegister.RegisterInstruction.BfieldAddress+DestinationRegister.RegisterInstruction.BfieldAddress
                case .DotI: // Whole instruction   =>  Whole instruction
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = SourceRegister.RegisterInstruction.AfieldAddress+DestinationRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = SourceRegister.RegisterInstruction.BfieldAddress+DestinationRegister.RegisterInstruction.BfieldAddress
                }
            case .SUB:
                print("SUB")
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA: //  A operand  =>  A operand
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress-SourceRegister.RegisterInstruction.AfieldAddress
                case .DotB: //  B operand  =>  B operand
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress-SourceRegister.RegisterInstruction.BfieldAddress
                case .DotAB: //  A operand  =>  B operand
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress-SourceRegister.RegisterInstruction.AfieldAddress
                case .DotBA: //  B operand  =>  A operand
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress-SourceRegister.RegisterInstruction.BfieldAddress
                case .DotF: //  A and B operands  =>  A and B operands
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress-SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress-SourceRegister.RegisterInstruction.BfieldAddress
                case .DotX: //  A and B operands  =>  B and A operands
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress-SourceRegister.RegisterInstruction.BfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress-SourceRegister.RegisterInstruction.AfieldAddress
                case .DotI: // Whole instruction   =>  Whole instruction
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress-SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress-SourceRegister.RegisterInstruction.BfieldAddress
                }
            case .MUL:
                print("MUL")
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA: //  A operand  =>  A operand
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress*SourceRegister.RegisterInstruction.AfieldAddress
                case .DotB: //  B operand  =>  B operand
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress*SourceRegister.RegisterInstruction.BfieldAddress
                case .DotAB: //  A operand  =>  B operand
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress*SourceRegister.RegisterInstruction.AfieldAddress
                case .DotBA: //  B operand  =>  A operand
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress*SourceRegister.RegisterInstruction.BfieldAddress
                case .DotF: //  A and B operands  =>  A and B operands
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress*SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress*SourceRegister.RegisterInstruction.BfieldAddress
                case .DotX: //  A and B operands  =>  B and A operands
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress*SourceRegister.RegisterInstruction.BfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress*SourceRegister.RegisterInstruction.AfieldAddress
                case .DotI: // Whole instruction   =>  Whole instruction
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress*SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress*SourceRegister.RegisterInstruction.BfieldAddress
                }
            case .DIV:
                print("DIV")
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA: //  A operand  =>  A operand
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress/SourceRegister.RegisterInstruction.AfieldAddress
                case .DotB: //  B operand  =>  B operand
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress/SourceRegister.RegisterInstruction.BfieldAddress
                case .DotAB: //  A operand  =>  B operand
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress/SourceRegister.RegisterInstruction.AfieldAddress
                case .DotBA: //  B operand  =>  A operand
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress/SourceRegister.RegisterInstruction.BfieldAddress
                case .DotF: //  A and B operands  =>  A and B operands
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress/SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress/SourceRegister.RegisterInstruction.BfieldAddress
                case .DotX: //  A and B operands  =>  B and A operands
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress/SourceRegister.RegisterInstruction.BfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress/SourceRegister.RegisterInstruction.AfieldAddress
                case .DotI: // Whole instruction   =>  Whole instruction
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress/SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress/SourceRegister.RegisterInstruction.BfieldAddress
                }
            case .MOD:
                print("MOD")
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA: //  A operand  =>  A operand
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress%SourceRegister.RegisterInstruction.AfieldAddress
                case .DotB: //  B operand  =>  B operand
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress%SourceRegister.RegisterInstruction.BfieldAddress
                case .DotAB: //  A operand  =>  B operand
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress%SourceRegister.RegisterInstruction.AfieldAddress
                case .DotBA: //  B operand  =>  A operand
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress%SourceRegister.RegisterInstruction.BfieldAddress
                case .DotF: //  A and B operands  =>  A and B operands
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress%SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress%SourceRegister.RegisterInstruction.BfieldAddress
                case .DotX: //  A and B operands  =>  B and A operands
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress%SourceRegister.RegisterInstruction.BfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress%SourceRegister.RegisterInstruction.AfieldAddress
                case .DotI: // Whole instruction   =>  Whole instruction
                    Core[DestinationRegister.RegisterAddress].AfieldAddress = DestinationRegister.RegisterInstruction.AfieldAddress%SourceRegister.RegisterInstruction.AfieldAddress
                    Core[DestinationRegister.RegisterAddress].BfieldAddress = DestinationRegister.RegisterInstruction.BfieldAddress%SourceRegister.RegisterInstruction.BfieldAddress
                }
            case .JMP:
                print("JMP")
                JumpAddress = SourceRegister.RegisterAddress
                JumpFlag = true
            case .JMZ:
                print("JMZ")
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA: //  A operand  =>  A operand
                    if SourceRegister.RegisterInstruction.AfieldAddress == 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotB: //  B operand  =>  B operand
                    if SourceRegister.RegisterInstruction.BfieldAddress == 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotAB: //  A operand  =>  B operand
                    if SourceRegister.RegisterInstruction.BfieldAddress == 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotBA: //  B operand  =>  A operand
                    if SourceRegister.RegisterInstruction.AfieldAddress == 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotF: //  A and B operands  =>  A and B operands
                    if SourceRegister.RegisterInstruction.AfieldAddress == 0 && SourceRegister.RegisterInstruction.BfieldAddress == 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotX: //  A and B operands  =>  B and A operands
                    if SourceRegister.RegisterInstruction.AfieldAddress == 0 && SourceRegister.RegisterInstruction.BfieldAddress == 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotI: // Whole instruction   =>  Whole instruction
                    if SourceRegister.RegisterInstruction.AfieldAddress == 0 && SourceRegister.RegisterInstruction.BfieldAddress == 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                }
            case .JMN:
                print("JMN")
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA: //  A operand  =>  A operand
                    if SourceRegister.RegisterInstruction.AfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotB: //  B operand  =>  B operand
                    if SourceRegister.RegisterInstruction.BfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotAB: //  A operand  =>  B operand
                    if SourceRegister.RegisterInstruction.BfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotBA: //  B operand  =>  A operand
                    if SourceRegister.RegisterInstruction.AfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotF: //  A and B operands  =>  A and B operands
                    if SourceRegister.RegisterInstruction.AfieldAddress != 0 && SourceRegister.RegisterInstruction.BfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotX: //  A and B operands  =>  B and A operands
                    if SourceRegister.RegisterInstruction.AfieldAddress != 0 && SourceRegister.RegisterInstruction.BfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotI: // Whole instruction   =>  Whole instruction
                    if SourceRegister.RegisterInstruction.AfieldAddress != 0 && SourceRegister.RegisterInstruction.BfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                }
            case .DJZ:
                print("Error: DJZ is not implemented")
            case .DJN:
                print("DJN")
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA: //  A operand  =>  A operand
                    if SourceRegister.RegisterInstruction.AfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotB: //  B operand  =>  B operand
                    if SourceRegister.RegisterInstruction.BfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotAB: //  A operand  =>  B operand
                    if SourceRegister.RegisterInstruction.BfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotBA: //  B operand  =>  A operand
                    if SourceRegister.RegisterInstruction.AfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotF: //  A and B operands  =>  A and B operands
                    if SourceRegister.RegisterInstruction.AfieldAddress != 0 && SourceRegister.RegisterInstruction.BfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotX: //  A and B operands  =>  B and A operands
                    if SourceRegister.RegisterInstruction.AfieldAddress != 0 && SourceRegister.RegisterInstruction.BfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                case .DotI: // Whole instruction   =>  Whole instruction
                    if SourceRegister.RegisterInstruction.AfieldAddress != 0 && SourceRegister.RegisterInstruction.BfieldAddress != 0 {
                        JumpAddress = SourceRegister.RegisterAddress
                        JumpFlag = true
                    }
                }
            case .CMP,.SEQ:
                print("CMP or SEQ")
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA: //  A operand  =>  A operand
                    if SourceRegister.RegisterInstruction.AfieldAddress == DestinationRegister.RegisterInstruction.AfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotB: //  B operand  =>  B operand
                    if SourceRegister.RegisterInstruction.BfieldAddress == DestinationRegister.RegisterInstruction.BfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotAB: //  A operand  =>  B operand
                    if SourceRegister.RegisterInstruction.AfieldAddress == DestinationRegister.RegisterInstruction.BfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotBA: //  B operand  =>  A operand
                    if SourceRegister.RegisterInstruction.BfieldAddress == DestinationRegister.RegisterInstruction.AfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotF: //  A and B operands  =>  A and B operands
                    if SourceRegister.RegisterInstruction.AfieldAddress == DestinationRegister.RegisterInstruction.AfieldAddress && SourceRegister.RegisterInstruction.BfieldAddress == DestinationRegister.RegisterInstruction.BfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotX: //  A and B operands  =>  B and A operands
                    if SourceRegister.RegisterInstruction.AfieldAddress == DestinationRegister.RegisterInstruction.BfieldAddress && SourceRegister.RegisterInstruction.BfieldAddress == DestinationRegister.RegisterInstruction.AfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotI: // Whole instruction   =>  Whole instruction
                    if SourceRegister.RegisterInstruction.OpCode == DestinationRegister.RegisterInstruction.OpCode &&
                        SourceRegister.RegisterInstruction.Modifier == DestinationRegister.RegisterInstruction.Modifier &&
                        SourceRegister.RegisterInstruction.AfieldAddressMode == DestinationRegister.RegisterInstruction.AfieldAddressMode &&
                        SourceRegister.RegisterInstruction.AfieldAddress == DestinationRegister.RegisterInstruction.AfieldAddress &&
                        SourceRegister.RegisterInstruction.BfieldAddressMode == DestinationRegister.RegisterInstruction.BfieldAddressMode &&
                        SourceRegister.RegisterInstruction.BfieldAddress == DestinationRegister.RegisterInstruction.BfieldAddress
                    {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                }
            case .SNE:
                print("Error: SNE is not implemented")
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA: //  A operand  =>  A operand
                    if SourceRegister.RegisterInstruction.AfieldAddress != DestinationRegister.RegisterInstruction.AfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotB: //  B operand  =>  B operand
                    if SourceRegister.RegisterInstruction.BfieldAddress != DestinationRegister.RegisterInstruction.BfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotAB: //  A operand  =>  B operand
                    if SourceRegister.RegisterInstruction.AfieldAddress != DestinationRegister.RegisterInstruction.BfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotBA: //  B operand  =>  A operand
                    if SourceRegister.RegisterInstruction.BfieldAddress != DestinationRegister.RegisterInstruction.AfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotF: //  A and B operands  =>  A and B operands
                    if SourceRegister.RegisterInstruction.AfieldAddress != DestinationRegister.RegisterInstruction.AfieldAddress && SourceRegister.RegisterInstruction.BfieldAddress != DestinationRegister.RegisterInstruction.BfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotX: //  A and B operands  =>  B and A operands
                    if SourceRegister.RegisterInstruction.AfieldAddress != DestinationRegister.RegisterInstruction.BfieldAddress && SourceRegister.RegisterInstruction.BfieldAddress != DestinationRegister.RegisterInstruction.AfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotI: // Whole instruction   =>  Whole instruction
                    if SourceRegister.RegisterInstruction.OpCode != DestinationRegister.RegisterInstruction.OpCode &&
                        SourceRegister.RegisterInstruction.Modifier != DestinationRegister.RegisterInstruction.Modifier &&
                        SourceRegister.RegisterInstruction.AfieldAddressMode != DestinationRegister.RegisterInstruction.AfieldAddressMode &&
                        SourceRegister.RegisterInstruction.AfieldAddress != DestinationRegister.RegisterInstruction.AfieldAddress &&
                        SourceRegister.RegisterInstruction.BfieldAddressMode != DestinationRegister.RegisterInstruction.BfieldAddressMode &&
                        SourceRegister.RegisterInstruction.BfieldAddress != DestinationRegister.RegisterInstruction.BfieldAddress
                    {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                }
            case .SLT:
                switch InstructionRegister.RegisterInstruction.Modifier {
                case .DotA: //  A operand  =>  A operand
                    if SourceRegister.RegisterInstruction.AfieldAddress < DestinationRegister.RegisterInstruction.AfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotB: //  B operand  =>  B operand
                    if SourceRegister.RegisterInstruction.BfieldAddress < DestinationRegister.RegisterInstruction.BfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotAB: //  A operand  =>  B operand
                    if SourceRegister.RegisterInstruction.AfieldAddress < DestinationRegister.RegisterInstruction.BfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotBA: //  B operand  =>  A operand
                    if SourceRegister.RegisterInstruction.BfieldAddress < DestinationRegister.RegisterInstruction.AfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotF: //  A and B operands  =>  A and B operands
                    if SourceRegister.RegisterInstruction.AfieldAddress < DestinationRegister.RegisterInstruction.AfieldAddress && SourceRegister.RegisterInstruction.BfieldAddress != DestinationRegister.RegisterInstruction.BfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotX: //  A and B operands  =>  B and A operands
                    if SourceRegister.RegisterInstruction.AfieldAddress < DestinationRegister.RegisterInstruction.BfieldAddress && SourceRegister.RegisterInstruction.BfieldAddress != DestinationRegister.RegisterInstruction.AfieldAddress {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                case .DotI: // Whole instruction   =>  Whole instruction
                    if SourceRegister.RegisterInstruction.OpCode != DestinationRegister.RegisterInstruction.OpCode &&
                        SourceRegister.RegisterInstruction.Modifier != DestinationRegister.RegisterInstruction.Modifier &&
                        SourceRegister.RegisterInstruction.AfieldAddressMode != DestinationRegister.RegisterInstruction.AfieldAddressMode &&
                        SourceRegister.RegisterInstruction.AfieldAddress != DestinationRegister.RegisterInstruction.AfieldAddress &&
                        SourceRegister.RegisterInstruction.BfieldAddressMode != DestinationRegister.RegisterInstruction.BfieldAddressMode &&
                        SourceRegister.RegisterInstruction.BfieldAddress != DestinationRegister.RegisterInstruction.BfieldAddress
                    {
                        JumpAddress = SourceRegister.RegisterAddress+1
                        JumpFlag = true
                    }
                }
            case .LDP:
                print("Error: LDP is not implemented")
            case .STP:
                print("Error: STP is not implemented")
            case .NOP:
                print("NOP")
            case .SPL:
                print("Error: SPL is not implemented")
            }
            if JumpFlag 
            {
                CoreWarriorQueue[CoreCurrentProcessIndex].WarriorCurrentCoreAddress = JumpAddress
            }
            else
            {
                CoreWarriorQueue[CoreCurrentProcessIndex].WarriorCurrentCoreAddress = CoreWrapAddress(CoreCurrentAddress,1,CoreSize)
            }
            CoreCurrentProcessIndex = CoreCurrentProcessIndex+1
            if CoreCurrentProcessIndex == CoreWarriorQueue.count
            {
                CoreCurrentProcessIndex = 0
            }
        }
        //date = Date()
        //milliseconds = String(Int(date.timeIntervalSince1970 * 1000))
        //print("E"+milliseconds)
    }
}





