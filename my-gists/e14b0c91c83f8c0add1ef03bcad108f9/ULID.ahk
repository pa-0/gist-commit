#Requires AutoHotkey v2.0

; Version: 20230.09.12.1
; https://gist.github.com/a3a21d9f7b1e08df4dc90d4ac64ba38a

; "Transpiled" from:
; https://github.com/ulid/javascript/blob/master/dist/index.js

; January 2, 2018 revision:
; https://github.com/ulid/javascript/blob/a5831206a11636c94d4657b9e1a1354c529ee4e9/dist/index.js

class ULID {

    static ENCODING := "0123456789ABCDEFGHJKMNPQRSTVWXYZ" ; Crockford's B32
        , ENCODING_LEN := 32 ; ENCODING.length
        , TIME_MAX := 281474976710655
        , TIME_LEN := 10
        , RANDOM_LEN := 16

    static Call(SeedTime := 0) {
        return this.Monotonic(SeedTime)
    }

    static Monotonic(SeedTime := 0) {
        static lastTime := 0, lastRandom := ""
        if (!SeedTime) {
            SeedTime := this._DateNow()
        }
        if (SeedTime <= lastTime) {
            lastRandom := this.IncrementBase32(lastRandom)
            incrementRandom := lastRandom
            return this.EncodeTime(lastTime, this.TIME_LEN) incrementRandom
        }
        lastTime := SeedTime
        lastRandom := this.EncodeRandom(this.RANDOM_LEN)
        newRandom := lastRandom
        return this.EncodeTime(SeedTime, this.TIME_LEN) newRandom
    }

    static Random(SeedTime := 0) {
        if (!SeedTime) {
            SeedTime := this._DateNow()
        }
        return this.EncodeTime(SeedTime, this.TIME_LEN) this.EncodeRandom(this.RANDOM_LEN)
    }

    static ReplaceCharAt(String, Index, Char) {
        if (Index > StrLen(String)) {
            return String
        }
        return SubStr(String, 1, Index) Char SubStr(String, Index + 2)
    }

    static IncrementBase32(Str) {
        char := ""
        charIndex := ""
        index := StrLen(Str)
        done := false
        while (!done && index--) {
            char := SubStr(Str, index + 1, 1)
            charIndex := InStr(this.ENCODING, char)
            if (charIndex = 0) {
                throw Error("incorrectly encoded string", -1)
            }
            if (charIndex = this.ENCODING_LEN) {
                len := SubStr(this.ENCODING, 1, 1)
                Str := this.ReplaceCharAt(Str, index, len)
                continue
            }
            len := SubStr(this.ENCODING, charIndex + 1, 1)
            done := this.ReplaceCharAt(Str, index, len)
        }
        if (!done) {
            throw Error("cannot increment this string", -1)
        }
        return done
    }

    static RandomChar() {
        rand := Random(1, this.ENCODING_LEN)
        return SubStr(this.ENCODING, rand, 1)
    }

    static EncodeTime(Now, Len) {
        if !(Now is Number) {
            throw Error(Now " must be a number", -1)
        } else if (Now > this.TIME_MAX) {
            throw Error("cannot encode time greater than " this.TIME_MAX, -1)
        } else if (Now < 0) {
            throw Error("time must be positive", -1)
        } else if !(Now is Integer) {
            throw Error("time must be an integer", -1)
        }
        str := ""
        while (Len--) {
            mdl := Mod(Now, this.ENCODING_LEN)
            str := SubStr(this.ENCODING, mdl + 1, 1) str
            Now := (Now - mdl) / this.ENCODING_LEN
        }
        return str
    }

    static EncodeRandom(Len) {
        str := ""
        while (Len--) {
            str .= this.RandomChar()
        }
        return str
    }

    static DecodeTime(Id) {
        timeLen := this.TIME_LEN
        if (StrLen(Id) != this.TIME_LEN + this.RANDOM_LEN) {
            throw Error("malformed ulid", -1)
        }
        time := ""
        while (timeLen--) {
            time .= SubStr(Id, timeLen + 1, 1)
        }
        if (time > this.TIME_MAX) {
            throw Error("malformed ulid, timestamp too large", -1)
        }
        carry := 0
        for (char in StrSplit(time)) {
            encodingIndex := InStr(this.ENCODING, char) - 1
            if (encodingIndex = -1) {
                throw Error("invalid character found: " char, -1)
            }
            carry += encodingIndex * this.ENCODING_LEN ** (A_Index - 1)
        }
        return carry
    }

    static _DateNow() { ; JS' Date.now()
        DllCall("GetSystemTimeAsFileTime", "Int64*", &ft := 0)
        return (ft - 116444736000000000) // 10000
    }

}

; spell:ignore 0123456789ABCDEFGHJKMNPQRSTVWXYZ Crockford's
