//
//  EmulatorCore.swift
//  LifeOnMARS
//
//  Created by Antonio Sanchez-Rivas on 3/2/2024.
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
        case SPL   // split (starts a second process at another address)
        case CMP   //   CMP     A       B   Compare operand  A with operand B. If they  are not  equal, skip next instruction;   otherwise  continue with next instruction.
        case SEQ   // skip if equal (compares two instructions, and skips the next instruction if they are equal)
        case SNE   // skip if not equal (compares two instructions, and skips the next instruction if they aren't equal)
        case SLT   // skip if lower than (compares two values, and skips the next instruction if the first is lower than the second)
        case LDP   // load from p-space (loads a number from private storage space)
        case STP   // save to p-space (saves a number to private storage space)
        case NOP   // no operation (does nothing)
        
    }
    
    enum RedCodeAddressMode {
        case Immediate   // #               The number  following  this symbol is the operand.
        case Direct      // $ or nothing    The  number  specifies  an  offset from the current instruction. Mars adds the  offset to the address of the current  instruction; the number stored at the location reached in this way is the operand.
        case Indirect    // @               The number  following  this symbol specifies an  offset from the current  instruction  to  a  location where the  relative address of theoperand is  found.  Mars  adds the offset to  the address of the current instruction and retrieves the number stored at the specified location; this number is then interpreted as  an offset  from its own address. The number found  at this second location is the operand.
    }
    
    struct RedCodeInstruction {
        
        var OpCode:RedCodeInstructionType = RedCodeInstructionType.DAT
        var AfieldAddressMode:RedCodeAddressMode = RedCodeAddressMode.Immediate
        var AfieldAddress:Int = 0
        var BfieldAddressMode:RedCodeAddressMode = RedCodeAddressMode.Immediate
        var BfieldAddress:Int = 0
        var InstructionColour:Color = .gray
        
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
    var CoreSize: Int = 800
    var CoreSizeInRows: Int
    var CoreSizeInCols: Int
    var CoreDrawSize : Int
    
    var CoreCurrentProcessIndex : Int = 0
    
    var Warriors : Array<Warrior>
    var CoreWarriorQueue : Array<WarriorQueue>
    
    @Published var Core : Array<RedCodeInstruction>
    
    init() {
        self.Warriors = []
        self.CoreWarriorQueue = []
        if self.CoreSize < 100 {
            self.CoreSizeInRows = 4
            self.CoreSizeInCols = 25
            CoreDrawSize = self.CoreSizeInRows*self.CoreSizeInCols
        }
        else if self.CoreSize < 1000
        {
            self.CoreSizeInRows = 20
            self.CoreSizeInCols = 50
            CoreDrawSize = self.CoreSizeInRows*self.CoreSizeInCols
        }
        else
        {
            self.CoreSizeInRows = 100
            self.CoreSizeInCols = 100
            CoreDrawSize = self.CoreSizeInRows*self.CoreSizeInCols
        }
        self.Core = Array<RedCodeInstruction>(repeating: RedCodeInstruction(),count:CoreDrawSize)
        for MyIndex in 0..<CoreSize {
            self.Core[MyIndex].InstructionColour = .black
        }
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
        case .DJN:
            FormattedString = FormattedString+"DJN"
        case .DJZ:
            FormattedString = FormattedString+"DJN"
        case .SPL:
            FormattedString = FormattedString+"SPL"
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
        }
        
        FormattedString = FormattedString + "    "
        
        switch CurrentRedCodeInstruction.AfieldAddressMode {
        case .Immediate:
            FormattedString = FormattedString+"#"
        case .Direct:
            FormattedString = FormattedString+"$"
        case .Indirect:
            FormattedString = FormattedString+"@"
        }
        
        FormattedString = FormattedString+String(format: "%06d", CurrentRedCodeInstruction.AfieldAddress)+","
        
        switch CurrentRedCodeInstruction.BfieldAddressMode {
        case .Immediate:
            FormattedString = FormattedString+"#"
        case .Direct:
            FormattedString = FormattedString+"$"
        case .Indirect:
            FormattedString = FormattedString+"@"
        }
        
        FormattedString = FormattedString+String(format: "%06d", CurrentRedCodeInstruction.BfieldAddress)
        
        return FormattedString
    }
    
    func LoadCore() {
        
        var TempRedCodeInstruction : Array<RedCodeInstruction> = []
        var TempCoreStartAddress : Int
        var WarriorCollision = Array<Bool>(repeating: false,count:CoreDrawSize)
        //var WarriorIndex : Int
        var WarriorCollisionFlag : Bool
        
        //      MOV 0, 1
        
        TempCoreStartAddress = Int.random(in: 0...CoreSize-1)
        //TempCoreStartAddress = 0
        
        TempRedCodeInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.MOV,AfieldAddressMode : RedCodeAddressMode.Direct,AfieldAddress:0,BfieldAddressMode : RedCodeAddressMode.Direct,BfieldAddress : 1,InstructionColour : .green))
        
        Warriors.append(Warrior(WarriorProgramID:0,WarriorProgramTitle:"Barry the IMP",WarriorCode:TempRedCodeInstruction,WarriorStartCoreAddress:TempCoreStartAddress,WarriorColour: .green))
        
        for WarriorIndex in 0...Warriors[0].WarriorCode.count-1 {
            WarriorCollision[CoreWrapAddress(TempCoreStartAddress,WarriorIndex,CoreSize)] = true
        }
        
        CoreWarriorQueue.append(WarriorQueue(WarriorProgramID: 0, WarriorProcessID: 0, WarriorProgramStatus: true, WarriorProcessStatus: true,WarriorCurrentCoreAddress : TempCoreStartAddress))
        Core[TempCoreStartAddress] = TempRedCodeInstruction[0]
        
        TempCoreStartAddress = Int.random(in: 0...CoreSize-1)
        //TempCoreStartAddress = CoreSize-1
        
        TempRedCodeInstruction = []
        
        //        ADD #4, 3        ; execution begins here
        //        MOV 2, @2
        //        JMP -2
        //        DAT #0, #0
        
        TempRedCodeInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.ADD,AfieldAddressMode : RedCodeAddressMode.Immediate,AfieldAddress:4,BfieldAddressMode : RedCodeAddressMode.Direct,BfieldAddress : 3,InstructionColour : .red))
        TempRedCodeInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.MOV,AfieldAddressMode : RedCodeAddressMode.Direct,AfieldAddress:2,BfieldAddressMode : RedCodeAddressMode.Indirect,BfieldAddress : 2,InstructionColour : .red))
        TempRedCodeInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.JMP,AfieldAddressMode : RedCodeAddressMode.Direct,AfieldAddress:-2,BfieldAddressMode : RedCodeAddressMode.Direct,BfieldAddress : 0,InstructionColour : .red))
        TempRedCodeInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.DAT,AfieldAddressMode : RedCodeAddressMode.Immediate,AfieldAddress:0,BfieldAddressMode : RedCodeAddressMode.Immediate,BfieldAddress : 0,InstructionColour : .red))
        
        Warriors.append(Warrior(WarriorProgramID:1,WarriorProgramTitle:"Kevin the Dwarf",WarriorCode:TempRedCodeInstruction,WarriorStartCoreAddress:TempCoreStartAddress,WarriorColour: .red))
        
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
    
    func ResetCore() {
        Core = Array<RedCodeInstruction>(repeating: RedCodeInstruction(),count:CoreDrawSize)
        for MyIndex in 0..<CoreSize
        {
            Core[MyIndex].InstructionColour = .black
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
        
        return (PassedCurrentAddress+PassedAddressIncrement) % PassedCoreSize
        
    }
    
    func CoreStepExecute()  {
        
        
        //var date = Date()
        //var milliseconds = String(Int(date.timeIntervalSince1970 * 1000))
        //print("S"+milliseconds)
        
        var CoreCurrentAddress: Int = 0
        var CoreCurrentInstruction:RedCodeInstruction = RedCodeInstruction.init()
        
        CoreCurrentAddress = CoreWarriorQueue[CoreCurrentProcessIndex].WarriorCurrentCoreAddress
        
        print(CoreCurrentAddress)
        print(Warriors[CoreCurrentProcessIndex].WarriorProgramTitle)
        
        CoreCurrentInstruction = Core[CoreCurrentAddress]
        switch CoreCurrentInstruction.OpCode {
        case .DAT:
            print("Bang! Warrior "+String(CoreWarriorQueue[CoreCurrentProcessIndex].WarriorProgramID)+" is dead")
        case .MOV:
            print("MOV")
            
            switch CoreCurrentInstruction.AfieldAddressMode
            {
            case .Direct:
                print("Direct")
            case .Immediate :
                print("Immediate")
            case .Indirect :
                print("Indirect")
            }
            Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.BfieldAddress,CoreSize)].OpCode = Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.AfieldAddress,CoreSize)].OpCode
            Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.BfieldAddress,CoreSize)].AfieldAddress = Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.AfieldAddress,CoreSize)].AfieldAddress
            Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.BfieldAddress,CoreSize)].BfieldAddress = Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.AfieldAddress,CoreSize)].BfieldAddress
            Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.BfieldAddress,CoreSize)].InstructionColour = CoreCurrentInstruction.InstructionColour
        case .ADD:
            print("Error: ADD is not implemented")
        case .SUB:
            print("Error: SUB is not implemented")
        case .MUL:
            print("Error: MUL is not implemented")
        case .DIV:
            print("Error: DIV is not implemented")
        case .MOD:
            print("Error: MOD is not implemented")
        case .JMP:
            print("Error: JMP is not implemented")
        case .JMZ:
            print("Error: JMZ is not implemented")
        case .JMN:
            print("Error: JMN is not implemented")
        case .DJN:
            print("Error: DJN is not implemented")
        case .DJZ:
            print("Error: DJZ is not implemented")
        case .SPL:
            print("Error: SPL is not implemented")
        case .CMP:
            print("Error: CMP is not implemented")
        case .SEQ:
            print("Error: SEQ is not implemented")
        case .SNE:
            print("Error: SNE is not implemented")
        case .SLT:
            print("Error: SLT is not implemented")
        case .LDP:
            print("Error: LDP is not implemented")
        case .STP:
            print("Error: STP is not implemented")
        case .NOP:
            print("Error: NOP is not implemented")
        }
        CoreWarriorQueue[CoreCurrentProcessIndex].WarriorCurrentCoreAddress = CoreWrapAddress(CoreCurrentAddress,1,CoreSize)
        CoreCurrentProcessIndex = CoreCurrentProcessIndex+1
        if CoreCurrentProcessIndex == CoreWarriorQueue.count
        {
            CoreCurrentProcessIndex = 0
        }
        //date = Date()
        //milliseconds = String(Int(date.timeIntervalSince1970 * 1000))
        //print("E"+milliseconds)
    }
}





