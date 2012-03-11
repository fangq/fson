! Copyright (c) 2012 Joseph A. Levin
!
! Permission is hereby granted, free of charge, to any person obtaining a copy of this
! software and associated documentation files (the "Software"), to deal in the Software
! without restriction, including without limitation the rights to use, copy, modify, merge,
! publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
! persons to whom the Software is furnished to do so, subject to the following conditions:
!
! The above copyright notice and this permission notice shall be included in all copies or 
! substantial portions of the Software.
!
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
! INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
! PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
! LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
! OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
! DEALINGS IN THE SOFTWARE.

!     
! File:   fson_path_m.f95
! Author: Joseph A. Levin
!
! Created on March 10, 2012, 11:01 PM
!

module fson_path_m
    
    use fson_value_m

    private
    
    public :: fson_path_get
    
    interface fson_path_get
        module procedure get_by_path
        module procedure get_integer
    end interface fson_path_get

contains
    !
    ! GET BY PATH
    !
    ! $     = root 
    ! @     = this
    ! .     = child object member
    ! []    = child array element
    !
    recursive subroutine get_by_path(this, path, p)
        type(fson_value), pointer :: this, p        
        character(len=*), intent(inout) :: path
        integer :: i, length, child_i
        character :: c
        
        ! default to assuming relative to this
        p => this
        
        child_i = 1
        
        length = len_trim(path)
        
        do i=1, length
            c = path(i:i)
            
            select case (c)
                case ("$")
                    ! root
                    ! not yet implemented, will need parent pointers on the values   
                    child_i = i
                case ("@")
                    ! this                    
                    p => this
                    child_i = i
                case (".")
                    ! get child member from p                    
                    p => fson_value_get(p, path(child_i:i-1))
                    
                    if(.not.associated(p)) then
                        return                                        
                    end if
                    
                    child_i = i+1
                case ("[")
                    ! get child element from p
                    child_i = i
                case default
                    
            end select            
        end do
        
        ! grab the last child if present in the path
        if (child_i <= length) then            
            p => fson_value_get(p, path(child_i:i-1))                    
            if(.not.associated(p)) then
                return
            else                
            end if
        end if
                
        
    end subroutine get_by_path
    
    !
    ! GET INTEGER
    !
    subroutine get_integer(this, path, value)
        type(fson_value), pointer :: this, p
        character(len=*) :: path
        integer :: value        
        
        
        nullify(p)                
        
        call get_by_path(this=this, path=path, p=p)
        
        if(.not.associated(p)) then
            print *, "value path not found: ", trim(path)
            return
        end if
                
        
        if(p % value_type == TYPE_INTEGER) then            
            value = p % value_integer
        else if (p % value_type == TYPE_REAL) then
            value = p % value_real
        else if (p % value_type == TYPE_LOGICAL) then
            if (p % value_logical) then
                value = 1
            else
                value = 0
            end if
        end if
        
    end subroutine get_integer
    

end module fson_path_m
