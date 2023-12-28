# a box of stringviews, you take when you need, then put it back
# why tho? because we can elide reallocates = faster runtime = less memory used
import stringview, sequtils, random, locks
logScope:
    topic = "Store"


const DefaultStoreCap = 80
const DefaultStrvCap = 4096


type StoreIML = object
    available: seq[Stringview]
    maxCap: int
    randomBuf: string
    lock: Lock


type Store* = ptr StoreIML

template safe(s: Store, body) =
    s.lock.acquire()
    try:
        body
    finally:
        s.lock.release()


proc newStore*(cap = DefaultStoreCap): Store =

    when hasThreadSupport:
        result = cast[Store](allocShared0(sizeof(StoreIML)))
    else:
        result = cast[Store](alloc0(sizeof(StoreIML)))

    initLock(result.lock)
    result.available = newSeqOfCap[Stringview](cap)
    result.available.setLen(cap)
    for i in 0 ..< cap:
        result.available[i] = newStringView(cap = DefaultStrvCap)
    result.maxCap = cap
    result.randomBuf = newStringOfCap(cap = 1_000_00) 
    result.randomBuf.setLen 1_000_00
    for i in 0 ..< result.randomBuf.len():
        result.randomBuf[i] = rand(char.low .. char.high).char

    trace "Initialized", cap = cap, allocated = cap * sizeof(StringView)


template requires(self: Store, count: int) =
    if self.available.len < count:
        warn "Allocating again", wasleft = self.available.len, requested = count, increase_to = self.maxCap*2
        quit(0)

        self.available.setLen(self.maxCap*2)

        for i in self.maxCap ..< self.maxCap*2:
            self.available[i] = newStringView(cap = DefaultStrvCap)

        self.maxCap = self.maxCap*2

proc pop*(self: Store): Stringview =
    safe(self):
        self.requires 1
        return self.available.pop()

proc reuse*(self: Store, v: sink Stringview) =
    safe(self):
        when not defined(release):
            if v.isNil():
                fatal "store cannot reuse Nil!"
                doAssert false
            if self.available.contains(v):
                fatal "store cannot reuse Twice!"
                doAssert false

        v.reset()


        self.available.add(v)

proc getRandomBuf*(self: Store, variety: int = 50): pointer =
    addr self.randomBuf[rand(0 .. variety)]
