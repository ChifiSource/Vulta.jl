module Vulta
using Toolips
using ToolipsSession
using ToolipsSVG

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

mutable struct VultaModifier <: ToolipsSession.AbstractComponentModifier
    rootc::Dict{String, Servable}
    changes::Vector{String}
    function VultaModifier(width::Int64, height::Int64, cm::ComponentModifier)
        new(cm.rootc, changes)
    end
end

function start(f::Function, c::Connection, width::Int64 = 1280,
    height::Int64 = 720; tickrate::Int64 = 100)
    script!(c, "vulta-listener", time = tickrate) do cm::ComponentModifier
        f(vm)
    end
    wind = svg("vulta-main", width = width, height = height)
end

function translate!(cm::VultaModifier, comp::Component{<:Any}, v::Vec2)

end

function is_colliding(vm::VultaModifier, s::Component{<:Any}, s2::Component{<:Any})

end

function force!(vm::VultaModifier, s::Component{<:Any}, force::Vec2)

end

function spawn!(vm::VultaModifier, s::Component{<:Any})

end

end # - module
