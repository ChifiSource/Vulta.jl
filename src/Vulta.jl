module Vulta
using Toolips
using ToolipsSession
using ToolipsSVG

abstract type VultaVector end

mutable struct

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
    delta::Int64
    rootc::Dict{String, Servable}
    comps::Dict{String, V}
    changes::Vector{String}
    function VultaModifier(delta::Int64, width::Int64, height::Int64, cm::ComponentModifier)
        new{Vec2}(cm.rootc, comps::Dict{String, Dict{String, V}}, changes)
    end
    function VultaModifier(delta::Int64, width::Int64, height::Int64, depth::Int64,
         cm::ComponentModifier)
        new{Vec2}(cm.rootc, , changes)
    end
end

function start(f::Function, c::Connection, width::Int64 = 1280,
    height::Int64 = 720; tickrate::Int64 = 100)
    script!(c, "vulta-listener", time = tickrate) do cm::ComponentModifier
        f(vm)
    end
    wind = svg("vulta-main", width = width, height = height)
    style!(wind, "padding" => 0px, "position" => "absolute")
    wind::Component{:svg}
end

function start(f::Function, c::Connection, width::Int64 = 1280,
    height::Int64 = 720, depth::Int64 = 1000; tickrate::Int64 = 100)
    throw!("3D has not been implemented")
    script!(c, "vulta-listener", time = tickrate) do cm::ComponentModifier
        vm = VultaModifier()
        f(vm)
    end
    wind = svg("vulta-main", width = width, height = height, depth = depth)
    style!(wind, "padding" => 0px, "position" => "absolute")
    wind::Component{:svg}
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

end # - module
