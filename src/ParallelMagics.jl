baremodule ParallelMagics

export MagicEx

module InternalPreludes
using Transducers: Executor
end

struct MagicEx{K} <: InternalPreludes.Executor
    kwargs::K
end

function reduce end
function mapreduce end
function foreach end
function collect end
function copy end
function map end
function map! end

function all end
function any end
function count end
function extrema end
function findall end
function findfirst end
function findlast end
function maximum end
function minimum end
function findmax end
function findmin end
function prod end
function sum end
function unique end

function argmax end
function argmin end

function issorted end

function cumsum end
function cumsum! end
function cumprod end
function cumprod! end
function accumulate end
function accumulate! end
function scan! end

function set end
function dict end

function enable_remark end
function disable_remark end

macro importall end

module Internal

import Folds
using Transducers: #
    Executor,
    IdentityTransducer,
    PreferParallel,
    SequentialEx,
    Transducers,
    foldl_basecase,
    retransform,
    start

import ParallelMagics: @importall
using ..ParallelMagics: MagicEx, ParallelMagics

include("utils.jl")
include("core.jl")
include("api.jl")

end  # module Internal

end  # baremodule ParallelMagics
