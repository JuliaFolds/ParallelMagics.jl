should_remark() = false

# Similar to `Transducers._reduce_basecase` but without `restachk` and `foldable(xs)`:
reduce_basecase(rf, init, xs) = foldl_basecase(rf, start(rf, init), xs)

function Transducers.transduce(xf::XF, rf::RF, init, xs, ex::MagicEx) where {XF,RF}
    rf1, xs1 = retransform(rf, xs |> xf)
    global FARGS = (reduce_basecase, (rf1, init, xs1))
    isparallelizable = _is_effect_free(reduce_basecase, _typesof((rf1, init, xs1)))

    if should_remark()
        outlined() do
            if isparallelizable
                @info "Auto-parallelized"
            else
                @info "Failed to auto-parallelize"
            end
        end
    end

    if isparallelizable
        return Transducers.transduce(
            IdentityTransducer(),
            rf1,
            init,
            xs1,
            PreferParallel(; ex.kwargs...),
        )
    else
        return Transducers.transduce(
            IdentityTransducer(),
            rf1,
            init,
            xs1,
            SequentialEx(; ex.kwargs...),
        )
    end
end
