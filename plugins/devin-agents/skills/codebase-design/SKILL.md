---
name: codebase-design
description: Shared vocabulary for designing deep modules. Use when designing or improving a module's interface, finding deepening opportunities, deciding where a seam goes, or making code more testable.
triggers:
  - user
  - model
---

You are designing or improving the structure of a codebase. This skill gives you a precise, shared vocabulary for reasoning about modules, interfaces, depth, and seams. Use it when you are designing a new module, evaluating an existing one, deciding where a test boundary goes, or making code more testable.

Precise vocabulary prevents the vague talk ("make it more modular," "add a layer") that leads to shallow designs. Use the terms below exactly as defined. Do not substitute "component," "service," "API," or "boundary" for the defined terms — each carries a different connotation and erodes precision.

## Glossary

### Module
A unit of code with a distinct **Interface** and **Implementation**. A module hides complexity behind its interface. It may be a function, a class, a package, a subsystem, or a service — the scale varies, but the structure is always the same: an interface that callers see and an implementation that callers do not.

### Interface
The set of inputs and outputs a **Module** exposes to its callers, plus the rules governing their use (preconditions, postconditions, invariants, error cases). The interface is the *contract*. Everything not in the interface is free to change.

### Implementation
The code inside a **Module** that fulfills the contract defined by its **Interface**. Callers must not depend on implementation details. If they do, the implementation cannot change without breaking callers.

### Depth
A measure of how much complexity a **Module** hides relative to the complexity it exposes. A deep module has a small **Interface** and a large **Implementation**: it hides a lot behind a little. A shallow module has a large interface and a small implementation: it hides little behind a lot. Depth is the primary quality metric for a module.

### Seam
A **Module** boundary chosen specifically as the place where behavior is observed and tested. A seam is an **Interface** that is also a test surface: you can drive the module through it and assert on its outputs without touching the **Implementation**. Not every interface is a seam — a seam is an interface you have *agreed* to test through.

### Adapter
A thin **Module** that translates between two incompatible **Interfaces** without adding meaningful logic. An adapter's **Implementation** is small by design; it exists to bridge, not to compute. One adapter between two modules is a *hypothetical seam* (the boundary could be tested, but nothing tests it yet). Two adapters around the same module — one on each side — indicate a *real seam*: the module is fully isolated and testable through its adapters.

### Leverage
The ratio of capability delivered to interface surface exposed. A module with high leverage does a lot for the caller with a small interface. Depth and leverage are closely related: deeper modules tend to have higher leverage. Seek leverage when designing interfaces — every parameter, option, and return field is a cost the caller bears.

### Locality
The degree to which the code and knowledge needed to understand or change a behavior live close together. High locality means a change touches one **Module** and stays within it. Low locality means a change ripples across many modules, requiring the changer to hold many things in their head at once. Good design maximizes locality: related decisions co-locate, unrelated decisions do not entangle.

## Deep vs shallow modules

**Deep module:** small **Interface** + large **Implementation**. The module hides substantial complexity behind a narrow contract. Callers learn a little and get a lot. Example: a module that exposes one function `compress(data) -> bytes` but internally implements a sophisticated algorithm with many internal helpers. The caller's mental load is tiny; the value delivered is large.

**Shallow module:** large **Interface** + small **Implementation**. The module exposes many methods, options, and configuration points but does little behind them. Callers learn a lot and get little. Example: a "manager" class with twenty methods that each delegate to one line of logic. The interface is wide, the implementation is trivial, and the caller carries the complexity the module should have absorbed.

**The goal is depth.** When you design or refactor, ask: *can I hide more behind less?* If the answer is yes, deepen the module.

## Principles

### Depth is a property of the interface, not the implementation
You cannot make a module deep by adding more code to its implementation. A module is deep only if its **Interface** is small *relative to* the complexity it hides. Adding a thousand lines of implementation behind a thousand-line interface produces a shallow module. The interface is what the caller pays; the implementation is what the caller gets. Depth is the ratio.

### The deletion test
Ask: *if I deleted this module's implementation and replaced it with a single line that returns a hardcoded correct answer, how much of the interface would still be justified?* The parts of the interface that exist only to support the current implementation — not to express the contract — are surface area you should remove. If the interface would shrink dramatically with a trivial implementation, the module is shallow: its width is driven by implementation needs, not by the problem's inherent complexity.

### The interface is the test surface
You test a module through its **Interface**, because that is the contract. Tests that reach past the interface into the **Implementation** couple to details that are supposed to be free to change. If you cannot test the behavior you care about through the interface, the interface is too narrow or too shallow — redesign it, do not punch through it.

### One adapter is a hypothetical seam; two are a real one
A single **Adapter** around a module suggests a boundary that *could* be a **Seam**, but nothing tests through it yet. It is hypothetical. When a module has adapters on both sides — input and output — it is fully isolated: you can swap either side in a test, drive the module through one adapter, and observe through the other. That is a real seam. If you are trying to make a module testable and it has only one adapter, ask what it would take to add the second.

## Designing for testability

Testability is not a separate concern from good design — it falls out of depth and clean seams. Apply these rules:

### Accept dependencies; do not create them
A module should receive its collaborators through its **Interface** (constructor parameters, function arguments, dependency injection), not reach out and construct or fetch them internally. A module that creates its own dependencies cannot be tested in isolation — you cannot substitute a fake without reaching past the interface. A module that *accepts* its dependencies can be tested by passing fakes through the same interface callers use.

### Return results; do not produce side effects
Prefer modules that take inputs and return outputs. Side effects (writing to a database, mutating shared state, sending a network request) make behavior hard to observe through the interface and hard to test without heavy setup. When a side effect is necessary, isolate it: the module that computes the decision returns it, and a separate module performs the effect. This separates "what should happen" (pure, testable) from "make it happen" (effectful, thin).

### Keep the surface area small
Every public method, parameter, option, and return field is part of the **Interface** and therefore part of the test surface. A wide interface demands wide tests and couples callers to more of the module's shape. Narrow the interface to the essential contract. Push options behind defaults; push rare cases behind a separate, deeper module rather than another parameter on an existing one.

## Relationships between the concepts

- **Module** is the unit. **Interface** and **Implementation** are its two faces.
- **Depth** measures the ratio of implementation to interface. Deep = much hidden, little exposed.
- **Leverage** is the caller's experience of depth: high leverage means a small interface delivers large capability.
- **Seam** is an interface chosen as a test surface. Every seam is an interface; not every interface is a seam.
- **Adapter** is the mechanism that makes a seam real. One adapter = hypothetical seam; two = real seam.
- **Locality** is the system-level consequence of good modules and deep interfaces: changes stay local because callers depend only on narrow interfaces, not on sprawling implementations.
- **Testability** emerges from accepting dependencies (so they can be faked), returning results (so behavior is observable), and small surface area (so the seam is narrow).

Designing for depth, leverage, and locality produces modules that are deep, testable, and cheap to change. Designing for shallow "modularity" — many small modules with wide interfaces — produces the opposite: a codebase where every change ripples and every test is brittle.
