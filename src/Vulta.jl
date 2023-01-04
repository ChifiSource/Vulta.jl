module Vulta
using Toolips
using ToolipsSession
using ToolipsSVG
import ToolipsSession: rpc!

abstract type VultaVector end

mutable struct Vec2 <: VultaVector
    x::Int64
    y::Int64
end

mutable struct Vec3 <: VultaVector
    x::Int64
    y::Int64
    z::Int64
end

mutable struct VultaModifier{V <: VultaVector} <: ToolipsSession.AbstractComponentModifier
    c::Connection
    delta::Int64
    rootc::Dict{String, Servable}
    comps::Dict{String, V}
    changes::Vector{String}
    function VultaModifier(c::Connection,
        delta::Int64, width::Int64, height::Int64, cm::ComponentModifier)
        comps::Dict{String, Vec2} = Dict{String, Vec2}()
        for comp in cm.rootc
            if comp[2].tag ==  "circle"
                push!(comps, comp[2].name => Vec2(parse(Int64, comp[2]["cx"]),
                                                parse(Int64, comp[2]["cy"])))
            end
        end
        new{Vec2}(c, delta, cm.rootc, comps, cm.changes)
    end
    function VultaModifier(delta::Int64, width::Int64, height::Int64, depth::Int64,
         cm::ComponentModifier)
         throw!("3D has not been implemented")
    end
end

function open(f::Function, c::Connection, bod::Component{:body},
    width::Int64 = 1280, height::Int64 = 720; tickrate::Int64 = 100)
    open_rpc!(c, "vulta-rpc", tickrate = tickrate)
    push!(c[:Session].peers,
     getip(c) => Dict{String, Vector{String}}(getip(c) => Vector{String}()))
     delta::Int64 = 0
    script!(c, getip(c) * "rpc", time = tickrate) do cm::ComponentModifier
        delta += 1
        push!(cm.changes, join(c[:Session].peers[getip(c)][getip(c)]))
        vm = VultaModifier(c, delta, width, height, cm)
        f(vm)
        c[:Session].peers[getip(c)][getip(c)] = Vector{String}()
    end
    wind = svg("vulta-main", width = width, height = height)
    push!(bod, wind)
    style!(wind, "padding" => 0px, "position" => "absolute")
    write!(c, bod)
end

function rpc!(vm::VultaModifier)
    mods::String = find_client(vm)
    [push!(mod, join(cm.changes)) for mod in values(vm.c[:Session].peers[mods])]
    deleteat!(cm.changes, 1:length(cm.changes))
end

find_client(vm::VultaModifier) = findfirst(x -> getip(c) in keys(x),
                                            vm.c[:Session].peers)

function close(vm)

end

function connect(f::Function, c::Connection, bod::Component{:body}, ip::String,
    width::Int64 = 1280, height::Int64 = 720; tickrate::Int64 = 100)
end

function open(f::Function, c::Connection, width::Int64 = 1280,
    height::Int64 = 720, depth::Int64 = 1000; tickrate::Int64 = 100)
    throw!("3D has not been implemented")
end

function translate!(cm::VultaModifier{Vec2}, comp::Component{<:Any}, v::Vec2)

end

function is_colliding(vm::VultaModifier{Vec2}, s::Component{<:Any}, s2::Component{<:Any})

end

function force!(vm::VultaModifier{Vec2}, s::Component{<:Any}, force::Vec2)

end

function spawn!(vm::VultaModifier{Vec2}, s::Component{<:Any},
    v::Vec2 = Vec2(0, 0))

end

function spawn!(vm::VultaModifier{Vec2}, s::Component{:circle}, v::Vec2 = Vec2(0, 0))
    s["cx"] = v.x; s["cy"] = v.y
    append!(vm, "vulta-main", s)
end

export spawn!, translate!, VultaModifier, Vec2, Vec3, force!, is_colliding
end # - module
