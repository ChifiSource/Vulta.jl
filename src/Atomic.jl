const vulta_energy::Int64 = 1
const vulta_temp::Int64 = 1
const vulta_decay::Int64 = 2
const vulta_relativity::Int64 = 1
const vulta_distance::Int64 = 1

abstract type AbstractMolecule <: Servable

function vmass(i::Float64)
    Int64(round(i * 0.99226036912))
end     # the rest of these
# 1  2  3  4  5  6  7  8 | 1 2 3 4 5 6 7 8
# x, y, z, r, g, b, a, m | e
mutable struct Molecule{S <: Any} <: AbstractMolecule
    name::String
    x::Int64
    y::Int64
    z::Int64
    Molecule(s::Symbol, name::String) = new{Symbol(s)}(name,
    vmass(mass),
        name)
end

t(v::Vector{AbstractMolecule}) = VultaVector([])
classify!(m::Molecule{<:Any})

function lod!()

end

mutable struct VultaTensor{n <: } <: AbstractTensor
    x::Vector{Int64}
    y::Vector{Int64}
    z::Vector{Int64}
    VultaTensor{}()
end

VultaStreamVector(path::String) = StreamVector{Int64}(path, 8)

VultaStreamTensor(vec::Vector{Int64}) = StreamFrame{Int64}(length(vec))

abstract type AbstractDimensions  <: Servable end
