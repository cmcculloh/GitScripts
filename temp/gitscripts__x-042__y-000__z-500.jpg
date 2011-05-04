#!/bin/bash
# stack.sh: push-down stack simulation

#  Similar to the CPU stack, a push-down stack stores data items
#+ sequentially, but releases them in reverse order, last-in first-out.



function _inistack () {
    # private function
    # call at the beginning of each procedure
    # defines: _keys _values _ptr
    #
    # Usage: _inistack NAME
    local name=$1
	declare -a ${name}
    _basePointer=${name}_basePointer
    _stackPointer=${name}_stackPointer
    _stackData=${name}_stackData
    _keys=_${name}_keys
    _values=_${name}_values
    _ptr=_${name}_ptr
}

function newstack () {
    # Usage: newstack NAME
    #        NAME should not contain spaces or dots.
    #        Actually: it must be a legal name for a Bash variable.
    # We rely on Bash automatically recognising arrays.
    local name=$1 
    local _basePointer _stackPointer _stackData _keys _values _ptr
    _inistack ${name}
    eval ${_basePointer}=100
    eval ${_stackPointer}=${_basePointer}
    eval ${_stackData}=
    eval ${_ptr}=0
}



#_basePointer=100  #  Base Pointer of stack array.
                  #  Begin at element 100.

#  Stack Pointer.
#_stackPointer=$_basePointer
                  #  Initialize it to "base" (bottom) of stack.

#_stackData=             #  Contents of stack location.  
                  #  Must use global variable,
                  #+ because of limitation on function return range.


                  # 100     Base pointer       <-- Base Pointer
                  #  99     First data item
                  #  98     Second data item
                  # ...     More data
                  #         Last data item     <-- Stack pointer



#declare -a stack





function addhash () {
    # Usage: addhash NAME KEY 'VALUE with spaces'
    #        arguments with spaces need to be quoted with single quotes ''
    local name=$1 k="$2" v="$3" 
    local _keys _values _ptr
    _inihash ${name}

    #echo "DEBUG(addhash): ${_ptr}=${!_ptr}"

    eval let ${_ptr}=${_ptr}+1
    eval "$_keys[${!_ptr}]=\"${k}\""
    eval "$_values[${!_ptr}]=\"${v}\""
}


push()            # Push item on stack.
{
    local name=$1 

    if [ -z "$2" ]    # Nothing to push?
	then
	  return
	fi
	
    local _basePointer _stackPointer _stackData _keys _values _ptr
    _inistack ${name}

	# Bump stack pointer.
    eval let ${_stackPointer}=${_stackPointer}-1	
	${name}[$_stackPointer]=$2

	return
}

pop()                    # Pop item off stack.
{
    local name=$1 
    if [ -z "$2" ]    # Nothing to push?
	then
	  return
	fi
	
    local _basePointer _stackPointer _stackData _keys _values _ptr
    _inistack ${name}

	local _stackData=                    # Empty out data item.

	if [ "${_stackPointer}" -eq "${_basePointer}" ]   # Stack empty?
	then
	  return
	fi                       #  This also keeps _stackPointer from getting past 100,
		                     #+ i.e., prevents a runaway stack.


	local _stackData=${name}[${_stackPointer}]
    eval let ${_stackPointer}=${_stackPointer}+1 # Bump stack pointer.	
	return
}



pop()                    # Pop item off stack.
{
    local name=$1 
    if [ -z "$2" ]    # Nothing to push?
	then
	  return
	fi
	
    local _basePointer _stackPointer _stackData _keys _values _ptr
    _inistack ${name}



	local _stackData=                    # Empty out data item.

	if [ "${_stackPointer}" -eq "${_basePointer}" ]   # Stack empty?
	then
	  return
	fi                       #  This also keeps _stackPointer from getting past 100,
		                     #+ i.e., prevents a runaway stack.

	local _stackData=${name}[$_stackPointer]
    eval let ${_stackPointer}=${_stackPointer}-1 # Bump stack pointer.	
	return
}

stack_getIndex()          # Find out what's happening.
{
	echo "$_stackPointer"
}

stack_getValue()          # Find out what's happening.
{
	_stackData=${stack[$_stackPointer]}
	echo "$_stackData"
}


status_report()          # Find out what's happening.
{
	echo "-------------------------------------"
	echo "REPORT"
	echo "Stack Pointer = $_stackPointer"
	echo "Just popped \""$_stackData"\" off the stack."
	echo "-------------------------------------"
	echo
}


