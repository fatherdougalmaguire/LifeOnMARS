import Foundation

//
//  EmulatorCore.swift
//  LifeOnMARS
//
//  Created by Antonio Sanchez-Rivas on 3/2/2024.
//
// MARS (Memory Array Redcode Simulator) emulator core in Swift

import Foundation

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

    var OpCode : RedCodeInstructionType = RedCodeInstructionType.DAT
    var AfieldAddressMode:RedCodeAddressMode = RedCodeAddressMode.Direct
    var AfieldAddress:Int = 0
    var BfieldAddressMode:RedCodeAddressMode = RedCodeAddressMode.Direct
    var BfieldAddress:Int = 0
    
//    init() {
//        opcode = RedCodeInstructionType.DAT
//        AfieldAddressMode=RedCodeAddressMode.Direct
//        AfieldAddress=0
//        BfieldAddressMode=RedCodeAddressMode.Direct
//        BfieldAddress=0
//    }
}

struct ProcessQueue {

    var Program:Int
    var Process:Int
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

let CoreSize = 8000

var Core = Array<RedCodeInstruction>(repeating: RedCodeInstruction(),count:CoreSize)
var CurrentAddress:Int = 0
var CurrentInstruction:RedCodeInstruction = RedCodeInstruction.init()

/*Core[CurrentAddress].opcode = RedCodeInstructionType.MOV
Core[CurrentAddress].AfieldAddressMode=RedCodeAddressMode.Direct
Core[CurrentAddress].AfieldAddress=0
Core[CurrentAddress].BfieldAddressMode=RedCodeAddressMode.Direct
Core[CurrentAddress].BfieldAddress=1

print("Start of MARS")

while CurrentAddress < CoreSize {

    CurrentInstruction = Core[CurrentAddress]
    print(CurrentAddress)
    switch CurrentInstruction.opcode {
    case .DAT:
        print("DAT")
    case .MOV:
        print("MOV")
        Core[CurrentAddress+CurrentInstruction.BfieldAddress].opcode = Core[CurrentAddress+CurrentInstruction.AfieldAddress].opcode
        Core[CurrentAddress+CurrentInstruction.BfieldAddress].AfieldAddress = Core[CurrentAddress+CurrentInstruction.AfieldAddress].AfieldAddress
        Core[CurrentAddress+CurrentInstruction.BfieldAddress].BfieldAddress = Core[CurrentAddress+CurrentInstruction.AfieldAddress].BfieldAddress
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
    
    CurrentAddress = CurrentAddress+1
}

print("End of MARS")
*/
