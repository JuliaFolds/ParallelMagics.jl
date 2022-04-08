"""
    _is_effect_free(f, t::Type{<:Tuple}) -> ans::Bool

Return `true` if `f(args...)` with `args::t` is consdiered to be `:effect_free` as defined
in `@assume_effects`.
"""
function _is_effect_free(f::F, t) where {F}
    return Core.Compiler.is_effect_free(Core.Compiler.infer_effects(f, t))
end

_typesof(::Tuple{}) = Tuple{}
_typesof((a,)::Tuple{Any}) = Tuple{Core.Typeof(a)}
_typesof((a, b)::NTuple{2,Any}) = Tuple{Core.Typeof(a),Core.Typeof(b)}
_typesof((a, b, c)::NTuple{3,Any}) = Tuple{Core.Typeof(a),Core.Typeof(b),Core.Typeof(c)}
_typesof(args) = Tuple{map(Core.Typeof, args)...}

outlined(f, args...) = @noinline f(args...)
