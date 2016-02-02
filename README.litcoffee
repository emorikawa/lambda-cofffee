# λ-Calculus Explained via CoffeeScript

**Pull requests please to improve this document.**

Basic concepts of the λ-calculus implemented in CoffeeScript. Because of
CoffeeScript's elegant, Haskell-like function declrations and its easy
transformation to javascript, it is great at demonsrating implementations
of λ-calculus.

The **lambda abstraction** `λx.x` is equivalent to the mathematical
function `f(x) = x` is equivalent to the CoffeeScript function definition
`(x) -> x`.

The **application** of `(λx.x)(2)` is equivalent to the mathematical
function `f(x) = x where x=2` is equivalent to the CoffeeScript
`((x) -> x)(2)`.

We can use the λ-calculus to encode data, predicate logic, and recursion.
For a programmer this is one way to hint at the λ-calculus's ability to
compute all that is computable. Alonzo Church's methods of doing this
encoding are not immediately intuitive. By giving parallel examples in an
easily executable and familiar programming environment, it becomes easier
to adopt these concepts.

## Predicate Logic

Church booleans are an elegant way of representing "true" and "false".

    TRUE  = (x) -> (y) -> x # λx.λy.x
    FALSE = (x) -> (y) -> y # λx.λy.y

We implement a function `b` that converts Church Booleans to literal
Javscript booleans.

    b = (f) -> f(true)(false)

This can be printed out like so:

    console.log b(TRUE)  # --> true
    console.log b(FALSE) # --> false

We can then construct logic operators

    AND = (p) -> (q) -> p(q)(p)               # λp.λq.p q p
    OR  = (p) -> (q) -> p(p)(q)               # λp.λq.p p q

    NOT = (p) -> (a) -> (b) -> p(b)(a)        # λp.λa.λb.p b a
    IFTHENELSE = (p) -> (a) -> (b) -> p(a)(b) # λp.λa.λb.p a b

Note the symmetry between "AND" <-> "OR" and "NOT" <-> "IFTHENELSE".

We can apply the operators like so

    AND(TRUE)(TRUE) # --> TRUE

Note that the return value of `AND(TRUE)(TRUE)` is a "lambda abstraction"
(aka function) whose η-conversion is equivalent to `TRUE`. To verify this
we can use our javascript boolean converter to see the full truth table
output.

    console.log b AND(TRUE)(TRUE)   # --> true
    console.log b AND(TRUE)(FALSE)  # --> false
    console.log b AND(FALSE)(TRUE)  # --> false
    console.log b AND(FALSE)(FALSE) # --> false

We can also create predicates that return Church Booleans

    ISZERO = (n) -> n((x) -> FALSE)(TRUE) # λn.n (λx.FALSE) TRUE

We can use `IFTHENELSE` to perform logic

    IFTHENELSE(TRUE)(THREE)(FOUR)  # --> THREE
    IFTHENELSE(FALSE)(THREE)(FOUR) # --> FOUR
    IFTHENELSE(ISZERO(ZERO))(THREE)(FOUR) # --> THREE
    IFTHENELSE(ISZERO(ONE))(THREE)(FOUR)  # --> FOUR

## Church Numerals

We can represent the natural numbers using Church Numerals.

    $0 = ZERO  = (f) -> (x) -> x            # λf.λx.x
    $1 = ONE   = (f) -> (x) -> f x          # λf.λx.f x
    $2 = TWO   = (f) -> (x) -> f f x        # λf.λx.f (f x)
    $3 = THREE = (f) -> (x) -> f f f x      # λf.λx.f (f (f x))
    $4 = FOUR  = (f) -> (x) -> f f f f x    # λf.λx.f (f (f (f x)))
    $5 = FIVE  = (f) -> (x) -> f f f f f x  # λf.λx.f (f (f (f (f x))))

We implement a function `int` that converts a Church Numeral into a
literal javascript integer.

    int   = (n) -> n((x) -> ++x)(0)

We can then define operations that can use our Church Numerals to do math.

    SUCC = (n) -> (f) -> (x) -> f (n(f)(x)) # λn.λf.λx.f (n f x)

    PLUS = (m) -> (n) -> (f) -> (x) -> m(f)(n(f)(x)) # λm.λn.λf.λx.m f (n f x)
    PLUS = (m) -> (n) -> m(SUCC)(n) # λm.λn.m SUCC n

    MULT = (m) -> (n) -> (f) -> m n f # λm.λn.λf.m (n f)

    POW  = (b) -> (e) -> e b  # λb.λe.e b

    # λn.λf.λx.n (λg.λh.h (g f)) (λu.x) (λu.u)
    PRED = (n) -> (f) -> (x) ->
             n((g) -> (h) -> h g f)((u) -> x)((u) -> u)
    SUB = (m) -> (n) -> n(PRED)(m) # λm.λn.n PRED m,

Above we have defined the successor `SUCC`, addition `PLUS`,
multiplication `MULT`, power `POW`, predecessor `PRED`, and subtraction
`SUB` operators. The additive operators work by repeating an operation `m`
times. The subtraction operators are more complex.

These operators, when given Church Numerals perform as expected

    PLUS(ONE)(TWO) # --> THREE

We can use our `int` operator to convert a Church Numeral into a
Javascript integer.

    console.log int PLUS(ONE)(TWO)  # --> 3
    console.log int SUCC(ONE)       # --> 2
    console.log int MULT(TWO)(FIVE) # --> 10
    console.log int POW(TWO)(FIVE)  # --> 32
    console.log int PRED(TWO)       # --> 1
    console.log int SUB(THREE)(TWO) # --> 1
    console.log int SUB(TWO)(THREE) # --> 0

## Combinators

We can also define **combinators**, which are lambda expressions with no
free variables. The simplest is the Identity combinator

    I = (x) -> x # λx.x

A more useful combinator is the Y-Combinator. This allows us to use an
anonymous function recursively.

    Y = (g) -> ((x) -> g (x x))((x) -> g (x x)) # λg.(λx.g (x x)) (λx.g (x x))

For example, say we had the following FACTORIAL function

    # λr.λn.(1, if n = 0; else n × (r (n−1)))
    FACTORIAL = (r) -> (n) -> IFTHENELSE(ISZERO n)(ONE)(MULT(n)(r PRED(n)))

Since it is illegal to use our function name in the function body (since
λ-calculus abstractions are anonymous), we need to use the Y-Combinator.

    Y(FACTORIAL)(FOUR) # --> 24
