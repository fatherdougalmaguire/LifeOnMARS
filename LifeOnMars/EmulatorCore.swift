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
        case DAT   // data (kills the process)
        case MOV   // move (copies data from one address to another)
        case ADD   // add (adds one number to another)
        case SUB   // subtract (subtracts one number from another)
        case MUL   // multiply (multiplies one number with another)
        case DIV   // divide (divides one number with another)
        case MOD   // modulus (divides one number with another and gives the remainder)
        case JMP   // jump (continues execution from another address)
        case JMZ   // jump if zero (tests a number and jumps to an address if it's 0)
        case JMN   // jump if not zero (tests a number and jumps if it isn't 0)
        case DJN   // decrement and jump if not zero (decrements a number by one, and jumps unless the result is 0)
        case SPL   // split (starts a second process at another address)
        case CMP   // compare (same as SEQ)
        case SEQ   // skip if equal (compares two instructions, and skips the next instruction if they are equal)
        case SNE   // skip if not equal (compares two instructions, and skips the next instruction if they aren't equal)
        case SLT   // skip if lower than (compares two values, and skips the next instruction if the first is lower than the second)
        case LDP   // load from p-space (loads a number from private storage space)
        case STP   // save to p-space (saves a number to private storage space)
        case NOP   // no operation (does nothing)
    }
    
    enum RedCodeAddressMode {
        case Immediate   // #
        case Direct      // $ or nothing
        case Indirect    // @
    }
    
    struct RedCodeInstruction {
        
        var OpCode:RedCodeInstructionType = RedCodeInstructionType.DAT
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
    
    var CoreCycles = 1000
    var CoreRunning = false
    var CoreSize: Int = 8000
    
    var CoreCurrentProcessIndex : Int = 0
    
    var Warriors : Array<Warrior>
    var CoreWarriorQueue : Array<WarriorQueue>
    
    @Published var Core : Array<RedCodeInstruction>
    
    init() {
        self.Core = Array<RedCodeInstruction>(repeating: RedCodeInstruction(),count:CoreSize)
        self.Warriors = []
        self.CoreWarriorQueue = []
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
        
        var TempRedCoreInstruction : Array<RedCodeInstruction> = []
        var TempCoreStartAddress : Int
        
        //TempCoreStartAddress = Int.random(in: 0...CoreSize)
        //TempCoreStartAddress = Int.random(in: 0...30)
        TempCoreStartAddress = 23
        
        TempRedCoreInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.MOV,AfieldAddressMode : RedCodeAddressMode.Direct,AfieldAddress:0,BfieldAddressMode : RedCodeAddressMode.Direct,BfieldAddress : 1,InstructionColour : .green))
        
        Warriors.append(Warrior(WarriorProgramID:0,WarriorProgramTitle:"Barry the IMP",WarriorCode:TempRedCoreInstruction,WarriorStartCoreAddress:TempCoreStartAddress,WarriorColour: .green))
        CoreWarriorQueue.append(WarriorQueue(WarriorProgramID: 0, WarriorProcessID: 0, WarriorProgramStatus: true, WarriorProcessStatus: true,WarriorCurrentCoreAddress : TempCoreStartAddress))
        Core[TempCoreStartAddress] = TempRedCoreInstruction[0]
        
        //TempCoreStartAddress = Int.random(in: 0...CoreSize)
        //TempCoreStartAddress = Int.random(in: 0...30)
        TempCoreStartAddress = 28
        
        TempRedCoreInstruction = []
        
        //        ADD #4, 3        ; execution begins here
        //        MOV 2, @2
        //        JMP -2
        //        DAT #0, #0
        
        TempRedCoreInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.ADD,AfieldAddressMode : RedCodeAddressMode.Immediate,AfieldAddress:4,BfieldAddressMode : RedCodeAddressMode.Direct,BfieldAddress : 3,InstructionColour : .red))
        TempRedCoreInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.MOV,AfieldAddressMode : RedCodeAddressMode.Direct,AfieldAddress:2,BfieldAddressMode : RedCodeAddressMode.Indirect,BfieldAddress : 2,InstructionColour : .red))
        TempRedCoreInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.JMP,AfieldAddressMode : RedCodeAddressMode.Direct,AfieldAddress:-2,BfieldAddressMode : RedCodeAddressMode.Direct,BfieldAddress : 0,InstructionColour : .red))
        TempRedCoreInstruction.append(RedCodeInstruction(OpCode: RedCodeInstructionType.DAT,AfieldAddressMode : RedCodeAddressMode.Immediate,AfieldAddress:0,BfieldAddressMode : RedCodeAddressMode.Immediate,BfieldAddress : 0,InstructionColour : .red))
        
        Warriors.append(Warrior(WarriorProgramID:1,WarriorProgramTitle:"Kevin the Dwarf",WarriorCode:TempRedCoreInstruction,WarriorStartCoreAddress:TempCoreStartAddress,WarriorColour: .red))
        CoreWarriorQueue.append(WarriorQueue(WarriorProgramID: 1, WarriorProcessID: 0, WarriorProgramStatus: true, WarriorProcessStatus: true,WarriorCurrentCoreAddress : TempCoreStartAddress))
        Core[TempCoreStartAddress] = TempRedCoreInstruction[0]
        Core[TempCoreStartAddress+1] = TempRedCoreInstruction[1]
        Core[TempCoreStartAddress+2] = TempRedCoreInstruction[2]
        Core[TempCoreStartAddress+3] = TempRedCoreInstruction[3]
       
    }
    
    func ResetCore() {
        self.Core = Array<RedCodeInstruction>(repeating: RedCodeInstruction(),count:CoreSize)
        self.Warriors = []
        self.CoreWarriorQueue = []
    }
    
    func CoreRunMode(_ PassedRunMode : Bool ) {
        
        CoreRunning = PassedRunMode
        
    }
    
    func SetCoreCycles(_ PassedRunCycles : Int ) {
        
        CoreCycles = PassedRunCycles
        
    }
    
    func CoreWrapAddress ( _ PassedCurrentAddress : Int, _ PassedAddressIncrement : Int, _ PassedCoreSize : Int ) -> Int {
        
        var NewAddress : Int
        
        if PassedCurrentAddress+PassedAddressIncrement > PassedCoreSize-1
        {
            NewAddress = PassedAddressIncrement-(CoreSize-PassedCurrentAddress)
        }
        else
        {
            NewAddress = PassedCurrentAddress+PassedAddressIncrement
        }
        return NewAddress
        
    }
    
    func CoreExecute()  {
        
        var CoreCurrentAddress: Int = 0
        var CoreCurrentInstruction:RedCodeInstruction = RedCodeInstruction.init()
        
        for LoopIndex in (1...CoreCycles)
        {
            CoreCurrentAddress = CoreWarriorQueue[CoreCurrentProcessIndex].WarriorCurrentCoreAddress
            CoreCurrentInstruction = Core[CoreCurrentAddress]
            switch CoreCurrentInstruction.OpCode {
            case .DAT:
                print("DAT")
            case .MOV:
                print("MOV")
                Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.BfieldAddress,CoreSize)].OpCode = Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.AfieldAddress,CoreSize)].OpCode
                Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.BfieldAddress,CoreSize)].AfieldAddress = Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.AfieldAddress,CoreSize)].AfieldAddress
                Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.BfieldAddress,CoreSize)].BfieldAddress = Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.AfieldAddress,CoreSize)].BfieldAddress
                Core[CoreWrapAddress(CoreCurrentAddress,CoreCurrentInstruction.BfieldAddress,CoreSize)].InstructionColour = CoreCurrentInstruction.InstructionColour
            case .ADD:
                print("ADD")
            case .SUB:
                print("SUB")
            case .MUL:
                print("MUL")
            case .DIV:
                print("DIV")
            case .MOD:
                print("MOD")
            case .JMP:
                print("JMP")
            case .JMZ:
                print("JMZ")
            case .JMN:
                print("JMN")
            case .DJN:
                print("DJN")
            case .SPL:
                print("SPL")
            case .CMP:
                print("CMP")
            case .SEQ:
                print("SEQ")
            case .SNE:
                print("SNE")
            case .SLT:
                print("SLT")
            case .LDP:
                print("LDP")
            case .STP:
                print("STP")
            case .NOP:
                print("NOP")
            }
            CoreWarriorQueue[CoreCurrentProcessIndex].WarriorCurrentCoreAddress = CoreWrapAddress(CoreCurrentAddress,1,CoreSize)
            CoreCurrentProcessIndex = CoreCurrentProcessIndex+1
            if CoreCurrentProcessIndex == CoreWarriorQueue.count
            {
                CoreCurrentProcessIndex = 0
            }
        }
    }
    
    func CoreStepExecute()  {
        
        var CoreCurrentAddress: Int = 0
        var CoreCurrentInstruction:RedCodeInstruction = RedCodeInstruction.init()
        
        CoreCurrentAddress = CoreWarriorQueue[CoreCurrentProcessIndex].WarriorCurrentCoreAddress
        CoreCurrentInstruction = Core[CoreCurrentAddress]
        switch CoreCurrentInstruction.OpCode {
        case .DAT:
            print("Bang! Warrior "+String(CoreWarriorQueue[CoreCurrentProcessIndex].WarriorProgramID)+" is dead")
        case .MOV:
            print("MOV")
            
            //switch CoreCurrentInstruction.AfieldAddressMode
            //{
           // case .Direct:
                
           // case .Immediate :
                
          //  case .Indirect :
                
           // }
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
    }
}





