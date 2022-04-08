function base_folds_names()
    publicnames = Symbol[]
    for name in names(ParallelMagics; all = true)
        isdefined(Folds, name) || continue
        occursin("#", string(name)) && continue
        push!(publicnames, name)
    end
    return publicnames
end

for name in base_folds_names()
    @eval ParallelMagics.$name(args...; kwargs...) =
        Folds.$name(args..., MagicEx(); kwargs...)
end

macro importall()
    ex = Expr(:block, __source__)
    for name in base_folds_names()
        ref = GlobalRef(ParallelMagics, name)
        push!(ex.args, :(const $name = $ref))
    end
    esc(ex)
end

function ParallelMagics.enable_remark()
    @eval should_remark() = true
    return
end

function ParallelMagics.disable_remark()
    @eval should_remark() = false
    return
end
