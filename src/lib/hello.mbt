
type Id Int

fn op_equal(self: Id, other: Id) -> Bool {
  self._ == other._
}

enum TapeNode {
  Value(Double)
  Add(Int, Int)
  Mul(Int, Int)
}

struct Tape {
  nodes: Array[TapeNode]
}

fn Tape::new() -> Tape {
  {
    nodes: []
  }
}

fn value(self: Tape, val: Double) -> TapeTerm {
  let node = self.nodes.length()
  self.nodes.push(Value(val))
  {
    tape: self,
    node: node
  }
}

fn Tape::eval(self: Tape, term: Int) -> Double {
  match self.nodes[term] {
    Value(val) => val
    Add(lhs, rhs) => self.eval(lhs) + self.eval(rhs)
    Mul(lhs, rhs) => self.eval(lhs) * self.eval(rhs)
  }
}

fn Tape::diff(self: Tape, term: Int, wrt: Int) -> Double {
  if term == wrt {
    return 1.
  }
  match self.nodes[term] {
    Value(_) => 0.
    Add(lhs, rhs) => self.diff(lhs, wrt) + self.diff(rhs, wrt)
    Mul(lhs, rhs) => self.eval(lhs) * self.diff(rhs, wrt) + self.diff(lhs, wrt) * self.eval(rhs)
  }
}

struct TapeTerm {
  tape: Tape
  node: Int
}

fn op_add(self: TapeTerm, other: TapeTerm) -> TapeTerm {
  let ret = self.tape.nodes.length()
  self.tape.nodes.push(Add(self.node, other.node))
  {
    tape: self.tape,
    node: ret
  }
}

fn op_mul(self: TapeTerm, other: TapeTerm) -> TapeTerm {
  let ret = self.tape.nodes.length()
  self.tape.nodes.push(Mul(self.node, other.node))
  {
    tape: self.tape,
    node: ret
  }
}

fn eval(self: TapeTerm) -> Double {
  self.tape.eval(self.node)
}

fn diff(self: TapeTerm, wrt: TapeTerm) -> Double {
  self.tape.diff(self.node, wrt.node)
}

pub fn hello() -> String {
  let tape = Tape::new()
  let a = tape.value(42.)
  let b = tape.value(24.)
  let c = tape.value(3.)
  let node = (a + b) * c
  let val = node.eval()
  println("eval: \{val}")
  for x in [a, b, c] {
    let d = node.diff(x)
    println("diff: \{d}")
  }
  ""
}
