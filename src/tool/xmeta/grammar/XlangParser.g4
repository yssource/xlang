parser grammar XlangParser;

options { tokenVocab=XlangLexer; }


/* Entry Point */
xlang
    : compilation_unit
    ;

compilation_unit
    : using_directive* namespace_declaration*
    ;

// For lexer tests
xlang_lexer_tests
    : UUID
    ;
    
/* Basic Concepts */
namespace_name
    : namespace_or_type_name
    ;

type_name
    : namespace_or_type_name
    ;


namespace_or_type_name
    : IDENTIFIER type_argument_list?
    | namespace_or_type_name . IDENTIFIER type_argument_list?
    | qualified_alias_member
    ;

/* Types */ //TODO: Nullable Types?
type
    : value_type
    | class_type
    | array_type
    ;

value_type
    : BOOLEAN
    | STRING
    | INT16
    | INT32
    | INT64
    | UINT8
    | UINT16
    | UINT32
    | UINT64
    | CHAR16
    | GUID
    | SINGLE
    | DOUBLE
    ;

class_type
    : type_name
    | OBJECT
    | NILL
    ;

array_type
    : non_array_type OPEN_BRACKET CLOSE_BRACKET
    ;

non_array_type
    : value_type
    | class_type
    ;

// Remove nullable type, Causing left resursive problems
enum_integral_type
    : INT8
    | UINT8
    | INT16
    | UINT16
    | INT32
    | UINT32
    | INT64
    | UINT64
    ;

type_argument_list
    : LESS_THAN type (COMMA type)* GREATER_THAN
    ;

/* Expression */
expression
    : DECIMAL_INTEGER_LITERAL
    | HEXADECIMAL_INTEGER_LITERAL
    | BOOLEAN_LITERAL
    | REAL_LITERAL
    | CHARACTER_LITERAL
    | STRING_LITERAL
    | IDENTIFIER
    | UUID
    | NILL
    ;

/* Variables */ // TODO: Later
variable_declarator
    : IDENTIFIER
    | IDENTIFIER EQUAL variable_initializer
    ;

variable_initializer
    : expression
    | array_type
    ;

/* Attributes */
attributes
    : attribute_section*
    ;

attribute_section
    : OPEN_BRACKET (attribute_target COLON)? attribute_list CLOSE_BRACKET
    ;

// Attributes targets are subject to change
attribute_target
    : ASSEMBLY
    | MODULE
    | FIELD
    | EVENT
    | METHOD
    | PARAM
    | PROPERTY
    | RETURN
    | TYPE
    | PUBLIC
    ;

attribute_list
    : attribute (COMMA attribute)*
    ;

attribute
    : type_name attribute_arguments?
    ;

attribute_arguments
    : OPEN_PARENS positional_argument_list? CLOSE_PARENS
    | OPEN_PARENS positional_argument_list COMMA named_argument_list CLOSE_PARENS
    | OPEN_PARENS named_argument_list? CLOSE_PARENS
    ;

positional_argument_list
    : positional_argument (COMMA positional_argument)*
    ;

positional_argument
    : IDENTIFIER? expression
    ;

named_argument_list
    : named_argument (COMMA named_argument)*
    ;

named_argument
    : IDENTIFIER EQUAL expression
    ;

/* Namespaces */
namespace_declaration
    : NAMESPACE IDENTIFIER namespace_body SEMICOLON?
    ;

namespace_body
    : OPEN_BRACE using_directive* namespace_member_declaration* CLOSE_BRACE
    ;

using_directive
    : using_alias_directive
    | using_namespace_directive
    ;

using_alias_directive
    : USING IDENTIFIER EQUAL namespace_or_type_name SEMICOLON
    ;

using_namespace_directive
    : USING namespace_name SEMICOLON
    ;

namespace_member_declaration
    : namespace_declaration
    | class_declaration
    | struct_declaration
    | interface_declaration
    | enum_declaration
    | delegate_declaration
    ;

qualified_alias_member
    : IDENTIFIER DOUBLE_COLON IDENTIFIER type_argument_list?
    ;

//* Classes *//
class_declaration
    : attributes? class_modifier* CLASS IDENTIFIER type_parameter_list?
        class_base? class_body SEMICOLON?
    ;

class_modifier
    : SEALED
    | STATIC
    ;

type_parameter_list
    : LESS_THAN attributes? IDENTIFIER (COMMA attributes? IDENTIFIER)* GREATER_THAN
    ;

class_base
    : COLON class_type_base
    | COLON interface_type_list
    | COLON class_type_base COMMA interface_type_list
    ;

/* TODO: Determine whether class_type_base and interface_type_base should exist
 The only difference between class_type_base and interface_type_base is that
 class_type base can be Object or NULL which doesn't make sense in terms of inheritance.
 
 You can't really inherit from NULL. We can just remove this part of the grammar 
 and have it referto just type_name. 
 Let the semantic checking do the work of determining whether it is a class type or 
 interface type.  
*/
class_type_base
    : attributes? class_type
    ;

interface_type_list
    : interface_type_base (COMMA interface_type_base)*
    ;
    
interface_type_base
    : attributes? type_name
    ;

class_body
    : OPEN_BRACE class_member_declarations* CLOSE_BRACE
    ;

class_member_declarations
    : attributes OPEN_BRACE class_member* CLOSE_BRACE
    | class_member
    ;
    
class_member
    : method_declaration
    | property_declaration
    | event_declaration
    | class_constructor_declaration
    ;

method_declaration
    : method_modifiers? return_type IDENTIFIER type_parameter_list? OPEN_PARENS formal_parameter_list? CLOSE_PARENS SEMICOLON
    ;

method_modifiers
    : method_modifier
    | method_modifiers method_modifier
    ;

method_modifier
    : OVERRIDE
    | PROTECTED
    | STATIC
    | SEALED
    ;

formal_parameter_list
    : fixed_parameter (COMMA fixed_parameter)*
    ;

fixed_parameter
    : attributes? parameter_modifier? type IDENTIFIER
    ;

parameter_modifier
    : CONST REF
    | OUT
    ;

return_type
    : type
    | VOID
    ;

property_declaration
    : attributes? property_modifier* type IDENTIFIER OPEN_BRACE property_accessors CLOSE_BRACE SEMICOLON?
    ;

property_modifier
    : PROTECTED
    | STATIC
    ;

property_accessors
    : attributes? GET SEMICOLON
    | attributes? SET SEMICOLON
    | attributes? GET SEMICOLON SET SEMICOLON
    ;

event_declaration
    : attributes? event_modifier* EVENT type IDENTIFIER SEMICOLON
    | attributes? event_modifier* EVENT type IDENTIFIER OPEN_BRACE event_accessors CLOSE_BRACE
    ;

event_modifier
    : PROTECTED
    | STATIC
    ;

event_accessors
    : attributes? ADD SEMICOLON attributes? REMOVE SEMICOLON
    ;

class_constructor_declaration
    : attributes? IDENTIFIER OPEN_PARENS formal_parameter_list? CLOSE_PARENS SEMICOLON
    ;

/* Structs */
struct_declaration
    : attributes? STRUCT IDENTIFIER type_parameter_list?
        struct_body SEMICOLON
    ;

struct_body
    : OPEN_BRACE field_declaration* CLOSE_BRACE
    ;

field_declaration
    : type IDENTIFIER SEMICOLON
    // TODO: Add variable initializers (<type> <id> = <expression>;)
    ;

/* Interfaces */
interface_declaration
    : attributes? PARTIAL? INTERFACE
        IDENTIFIER type_parameter_list? interface_base? interface_body SEMICOLON?
    ;

interface_base
    : REQUIRES interface_type_list
    ;

interface_body
    : OPEN_BRACE interface_member_declaration* CLOSE_BRACE
    ;

interface_member_declaration
    : method_declaration
    | property_declaration
    | event_declaration
    ;

/* Enums */
enum_declaration
    : attributes? enum_modifier* ENUM IDENTIFIER enum_base? enum_body SEMICOLON?
    ;

enum_base
    : COLON enum_integral_type
    ;

enum_body
    : OPEN_BRACE CLOSE_BRACE
    | OPEN_BRACE enum_member_declaration (COMMA enum_member_declaration)* COMMA? CLOSE_BRACE
    ;

enum_modifier
    : PUBLIC
    ;

enum_member_declaration
    : attributes? IDENTIFIER
    | attributes? IDENTIFIER EQUAL enum_expression
    ;

enum_expression 
    : enum_decimal_integer
    | enum_hexdecimal_integer
    | enum_identifier;

enum_decimal_integer
    : DECIMAL_INTEGER_LITERAL;
    
enum_identifier
    : IDENTIFIER;

enum_hexdecimal_integer
    : HEXADECIMAL_INTEGER_LITERAL;

/* Delegates */
delegate_declaration
    : attributes? delegate_modifier* DELEGATE return_type
        IDENTIFIER type_parameter_list?
        OPEN_PARENS formal_parameter_list CLOSE_PARENS SEMICOLON
    ;

delegate_modifier
    : NEW
    | PUBLIC
    | PROTECTED
    | INTERNAL
    | PRIVATE
    ;

