// Prototype - Creational Design Pattern
// Deep copy and shallow copy examples

import Foundation

// MARK: - Prototype Design Pattern Container
struct PrototypeDesignPattern {
    
    // MARK: - Shallow Copy Example 1: Manual Copy Method
    /// A simple class demonstrating manual shallow copy
    /// Under the hood: Creates a NEW instance with copied values
    /// For value types (String, Int), this is effectively a deep copy
    /// For reference types nested inside, it would be shallow
    class ShallowCopyExampleOne {
        var name: String      // String is a value type (struct)
        var score: Int        // Int is a value type
        
        init(name: String, score: Int) {
            self.name = name
            self.score = score
        }
        
        /// Creates a SHALLOW copy by manually initializing a new instance
        /// Under the hood:
        /// - Allocates new memory for the new object
        /// - Copies the VALUES of name and score (not references)
        /// - Since String and Int are value types, they ARE deeply copied
        /// - If this had a class property, it would copy the REFERENCE (shallow)
        func shallowCopy() -> ShallowCopyExampleOne {
            // Returns a completely new instance with same values
            return ShallowCopyExampleOne(name: self.name, score: self.score)
        }
    }
    
    // MARK: - Shallow Copy Example 2: NSCopying Protocol
    /// Class conforming to NSCopying (Objective-C interoperability)
    /// Under the hood: Implements the standard copy protocol used by Cocoa/Cocoa Touch
    class ShallowCopyExampleTwo: NSObject, NSCopying {
        var name: String
        var score: Int
        
        init(name: String, score: Int) {
            self.name = name
            self.score = score
        }
        
        /// REQUIRED: NSCopying protocol method (NOT shallowCopy)
        /// Under the hood:
        /// - The protocol requires `copy(with zone: NSZone?) -> Any`
        /// - Returns `Any` because protocol is generic
        /// - NSZone is an Objective-C memory management concept (rarely used now)
        /// - Swift automatically calls this when you use `.copy` on the object
        func copy(with zone: NSZone? = nil) -> Any {
            // Return a new instance of THE SAME TYPE (not ShallowCopyExampleOne!)
            // This is the FIX: was returning wrong type before
            return ShallowCopyExampleTwo(name: self.name, score: self.score)
        }
        
        /// Convenience method to get typed copy (avoids casting)
        func shallowCopy() -> ShallowCopyExampleTwo {
            // Calls the protocol method and casts to correct type
            return self.copy() as! ShallowCopyExampleTwo
        }
    }
    
    // MARK: - Deep Copy Example 1: Address Class
    /// A class representing an address - used for nested deep copy demonstration
    /// Under the hood:
    /// - Conforms to Codable for JSON encoding/decoding
    /// - Codable automatically generates encoding/decoding logic
    /// - JSONEncoder converts object to DATA (flattens to bytes)
    /// - JSONDecoder reconstructs NEW object from DATA (creates new memory)
    class DeepCopy: Codable {
        var street: String
        var city: String
        
        init(street: String, city: String) {
            self.street = street
            self.city = city
        }

        // Explicit CodingKeys resolves many Codable issues
        enum CodingKeys: String, CodingKey {
            case street
            case city
        }
    }
    
    // MARK: - Deep Copy Example 2: Class with Nested Reference
    /// A class containing another class (reference type) - demonstrates TRUE deep copy
    /// Under the hood:
    /// - Without deep copy: `address` would be SHALLOW copied (same memory reference)
    /// - With JSON deep copy: NEW DeepCopy instance is created (different memory)
    class DeepCopyTwo: Codable {
        var name: String
        var address: DeepCopy  // This is a REFERENCE type (class)
        
        init(name: String, address: DeepCopy) {
            self.name = name
            self.address = address
        }
        
        // Explicit CodingKeys resolves many Codable issues
        enum CodingKeys: String, CodingKey {
            case name
            case address
        }

        /// EXTENSION-based deep copy method (see extension below)
        /// Under the hood:
        /// 1. JSONEncoder.encode(self) → Converts entire object graph to JSON data
        ///    - Recursively encodes `name` (String) and `address` (DeepCopy object)
        ///    - Creates a complete byte representation in memory
        /// 2. JSONDecoder.decode() → Creates FRESH instances from JSON data
        ///    - Allocates NEW memory for DeepCopyTwo
        ///    - Allocates NEW memory for DeepCopy (nested object)
        ///    - Result: completely independent object graph
        func deepCopy() -> DeepCopyTwo? {
            do {
                // Encode to JSON data (flattens the object)
                let encodedData = try JSONEncoder().encode(self)
                // Decode creates entirely new instances
                return try JSONDecoder().decode(DeepCopyTwo.self, from: encodedData)
            } catch {
                print("Deep copy failed: \(error)")
                return nil
            }
        }
    }
    
    // MARK: - Value Type Example (Struct)
    /// Struct demonstrating automatic deep copy (value semantics)
    /// Under the hood:
    /// - Swift structs have VALUE SEMANTICS by default
    /// - When you assign `let copy = original`, Swift creates a COMPLETE copy
    /// - Copy-on-Write (COW) optimization: memory shared until modification
    /// - First write triggers actual copy (performance optimization)
    struct DeepCopyExample {
        var name: String
        var age: Int
    }
}

// MARK: - Codable Extension for Generic Deep Copy
/// EXTENSION: Adds deepCopy() to ANY Codable type
/// Under the hood:
/// - Works for structs AND classes that conform to Codable
/// - Uses reflection-like encoding/decoding to clone any object
/// - Limitation: Properties must also be Codable
extension Encodable where Self: Decodable {
    /// Generic deep copy method for any Codable type
    /// Under the hood:
    /// 1. `self` is encoded to JSON data (entire object graph)
    /// 2. JSON data is decoded back into a NEW instance of same type
    /// 3. Result is completely independent from original
    func deepCopy() -> Self? {
        do {
            let encoded = try JSONEncoder().encode(self)
            return try JSONDecoder().decode(Self.self, from: encoded)
        } catch {
            print("Deep copy error: \(error)")
            return nil
        }
    }
}

// MARK: - Usage Examples with Demonstrations

// Create original shallow copy example
let shallowCopyExampleOne: PrototypeDesignPattern.ShallowCopyExampleOne = 
    PrototypeDesignPattern.ShallowCopyExampleOne(name: "Joe", score: 99)

// Create copy using manual shallowCopy method
// Under the hood: New instance allocated, values copied
let shallowCopyOneCopy = shallowCopyExampleOne.shallowCopy()

// Modify the copy to demonstrate independence
shallowCopyOneCopy.name = "Jane"
shallowCopyOneCopy.score = 100

print("=== Shallow Copy Example 1 (Manual) ===")
print("Original name: \(shallowCopyExampleOne.name)")   // "Joe" - unchanged
print("Copy name: \(shallowCopyOneCopy.name)")          // "Jane" - modified

// Create NSCopying example
let shallowCopyExampleTwo: PrototypeDesignPattern.ShallowCopyExampleTwo = 
    PrototypeDesignPattern.ShallowCopyExampleTwo(name: "Joe", score: 99)

// Create copy using NSCopying protocol (.copy() method)
// Under the hood: Swift calls copy(with:) internally
let shallowCopyTwoCopy = shallowCopyExampleTwo.shallowCopy()

// Modify to demonstrate independence
shallowCopyTwoCopy.name = "Jane"
shallowCopyTwoCopy.score = 100

print("\n=== Shallow Copy Example 2 (NSCopying) ===")
print("Original name: \(shallowCopyExampleTwo.name)")   // "Joe" - unchanged
print("Copy name: \(shallowCopyTwoCopy.name)")          // "Jane" - modified

// MARK: - DEEP COPY DEMONSTRATION WITH NESTED REFERENCES

// Create original object with nested address
let deepCopyExample: PrototypeDesignPattern.DeepCopyTwo = 
    PrototypeDesignPattern.DeepCopyTwo(
        name: "Joe", 
        address: PrototypeDesignPattern.DeepCopy(street: "123 Main St", city: "New York")
    )

// Create DEEP COPY using JSON encoding/decoding
// Under the hood:
// 1. Entire object graph encoded to JSON (including nested address)
// 2. New DeepCopyTwo AND new DeepCopy instances created
// 3. Complete independence from original
if let deepCopyExampleCopy = deepCopyExample.deepCopy() {
    // Modify nested reference in the copy
    let modifiedCopy = deepCopyExampleCopy // Get mutable reference
    let mutableCopy = modifiedCopy
    mutableCopy.address.city = "Los Angeles"  // Modify nested object
    
    print("\n=== Deep Copy Example (Nested Class) ===")
    print("Original city: \(deepCopyExample.address.city)")      // "New York" - UNCHANGED
    print("Copy city: \(mutableCopy.address.city)")              // "Los Angeles" - modified
    print("Same address object? \(deepCopyExample.address === mutableCopy.address)") // false - different memory
}

// Create another deep copy using the Codable extension
let deepCopyExampleTwo: PrototypeDesignPattern.DeepCopyTwo = 
    PrototypeDesignPattern.DeepCopyTwo(
        name: "Joe", 
        address: PrototypeDesignPattern.DeepCopy(street: "123 Main St", city: "New York")
    )

// Use generic extension method
if let extensionCopy = deepCopyExampleTwo.deepCopy() {
    let mutableExtensionCopy = extensionCopy
    mutableExtensionCopy.name = "Jane"
    
    print("\n=== Deep Copy Using Codable Extension ===")
    print("Original name: \(deepCopyExampleTwo.name)")   // "Joe"
    print("Copy name: \(mutableExtensionCopy.name)")     // "Jane"
}

// MARK: - STRUCT DEEP COPY (VALUE SEMANTICS - AUTOMATIC)

// Structs are deep copied AUTOMATICALLY by Swift
let structOriginal: PrototypeDesignPattern.DeepCopyExample = 
    PrototypeDesignPattern.DeepCopyExample(name: "Joe", age: 30)

// Assignment creates a complete copy (value semantics)
// Under the hood: Copy-on-Write optimization
// - Memory shared until one is modified
// - First modification triggers actual copy
let structCopy = structOriginal

// Modify the copy
var mutableStructCopy = structCopy
mutableStructCopy.name = "Jane"
mutableStructCopy.age = 25

print("\n=== Struct Deep Copy (Automatic Value Semantics) ===")
print("Original name: \(structOriginal.name)")   // "Joe" - unchanged
print("Original age: \(structOriginal.age)")     // 30 - unchanged
print("Copy name: \(mutableStructCopy.name)")    // "Jane" - modified
print("Copy age: \(mutableStructCopy.age)")      // 25 - modified

// MARK: - KEY DIFFERENCES SUMMARY
/*
 SHALLOW COPY vs DEEP COPY:

 SHALLOW COPY:
 - Copies the object BUT nested reference types share same memory
 - Modifying nested object affects original
 - Faster (less memory allocation)
 - Example: Copying array of class instances

 DEEP COPY:
 - Copies object AND all nested reference types recursively
 - Complete independence from original
 - Slower (more memory, JSON encoding overhead)
 - Example: Our DeepCopyTwo with nested address

 SWIFT VALUE TYPES (structs/enums):
 - Automatically deep copied (value semantics)
 - No manual implementation needed
 - Copy-on-Write optimizes performance
 */