SendMode Input
!z::
   loop 26 {
      i := Asc("a") + A_Index - 1
      loop 26 {
         j := Asc("a") + A_Index - 1
         loop 26 {
            k := Asc("a") + A_Index - 1
            l := Chr(i)
            m := Chr(j)
            n := Chr(k)
            Send, {%l% down}{%m% down}{%n% down}
            Sleep, 10
            Send, {%l% up}{%m% up}{%n% up}
            If GetKeyState("Esc")
               ExitApp
         }
      }
   }