# a box of stringviews, you take when you need, then put it back
# why tho? because we can elide reallocates = faster runtime = less memory used
import stringview, sequtils,random
logScope:
    topic = "Store"


const DefaultStoreCap = 500
const DefaultStrvCap = 4096

type Store* = ref object
    available: seq[Stringview]
    maxCap: int
    randomBuf:string 

proc newStore*(cap = DefaultStoreCap): Store =
    new result
    result.available = newSeqOfCap[Stringview](cap)
    result.available.setLen(cap)
    for i in 0 ..< cap:
        result.available[i] = newStringView(cap = DefaultStrvCap)
    result.maxCap = cap
    result.randomBuf = newStringOfCap(cap = 1_000_000) # 1 mb
    result.randomBuf.setLen 1_000_000
    for i in 0..< result.randomBuf.len():
        result.randomBuf[i] = rand(char.low .. char.high).char

    trace "Initialized", cap = cap, allocated = cap * sizeof(StringView)


template requires(self: Store, count: int) =
    if self.available.len < count:
        warn "Allocating again", wasleft = self.available.len, requested = count, increase_to = self.maxCap*2
        self.available.setLen(self.maxCap*2)

        for i in self.maxCap ..< self.maxCap*2:
            self.available[i] = newStringView(cap = DefaultStrvCap)

        self.maxCap = self.maxCap*2

proc pop*(self: Store): Stringview =
    self.requires 1
    return self.available.pop()

proc reuse*(self: Store, v: sink Stringview) =
    v.reset()
    self.available.add(move v)

proc getRandomBuf*(self: Store,variety : int = 50): pointer =
    addr self.randomBuf[rand(0 .. variety)]