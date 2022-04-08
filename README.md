# ParallelMagics: Safe parallelism using compiler analysis

ParallelMagics.jl is aiming at providing safe parallelism to Julia programmers such that

* "No-brainer" parallelism using compiler analysis; i.e., the code is parallelized only if
  the compiler guarantees the safety.
* (Wishlist) Static and dynamic detection of programs that are worth parallelizing.
* (Wishlist) Diagnosis mechanisms for understanding and fixing parallelizability of a
  program.

This package is very incomplete.  It is still rather a party trick than a usable library.

## Demo

ParallelMagics.jl provides APIs such as `ParallelMagics.sum` that may auto-parallelize an
invocation.  It also provides a macro `@importall` that is equivalent to `using
ParallelMagics: sum, reduce, map, ...` to auto-parallelize all supported functions in the
current lexical scope or a REPL session.

```julia
julia> using ParallelMagics

julia> ParallelMagics.@importall  # Use ParallelMagics's version of `sum` etc.

julia> sum === ParallelMagics.sum
true
```

To make it clear when ParallelMagics.jl works, let us enable the remark:

```julia
julia> ParallelMagics.enable_remark()
```

Calling ParallelMagics functions now automagically parallelize function

```julia
julia> sum(sin, 1:2^20)
[ Info: Auto-parallelized
0.21667559252423674
```

Since SinceParallelMagics.jl uses the compiler analysis, it can "see through" user-defined
functions and iterator comprehensions:

```julia
julia> user_defined_function(x) = sin(x);

julia> sum((user_defined_function(x) for x in 1:2^20 if isodd(x)))
[ Info: Auto-parallelized
0.03338891483674633
```

ParallelMagics.jl refuses to parallelize an invocation of its API if the compiler cannot
prove that the functions for computing the result and accessing the objects provided by the
user are all effect-free.  For example, writing to a global variable is considered
effectful.  Thus, ParallelMagics.jl refuses to call a function that updates a global
variable in parallel:

```julia
julia> EVIL = 0;

julia> sum(1:2^20) do x
           global EVIL += 1
           sin(x)
       end
[ Info: Failed to auto-parallelize
0.2166755925243159
```

(**Known bug:** Note that the result is different when not parallelized since the
computation tree is different for parallel and sequential implementations at the moment.)

ParallelMagics.jl also exports `MagicEx` executor.  It can be used with various JuliaFolds
packages such as [FLoops.jl](https://github.com/JuliaFolds/FLoops.jl).

```julia
using FLoops
using ParallelMagics

function good(xs)
    @floop MagicEx() for x in xs
        @reduce y += sin(x)
    end
    return y
end

EVIL = 0

function bad(xs)
    @floop MagicEx() for x in xs
        global EVIL += 1
        @reduce y += sin(x)
    end
    return y
end
```

```julia
julia> good(1:2^20)
[ Info: Auto-parallelized
0.21667559252423674

julia> bad(1:2^20)
[ Info: Failed to auto-parallelize
0.2166755925243159
```

## Acknowledgements

This approach heavily relies on the various improvements in the Julia compiler made by Keno
Fischer (ref: [JuliaLang/julia#43852](https://github.com/JuliaLang/julia/pull/43852)) and
Shuhei Kadowaki (ref:
[JuliaLang/julia#44822](https://github.com/JuliaLang/julia/pull/44822)).
