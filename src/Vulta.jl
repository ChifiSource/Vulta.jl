module Vulta
using Toolips
using ToolipsSession
import ToolipsSession: Modifier
import Toolips: write!, Servable
import Base: length, show, getindex, setindex!
using ToolipsSVG
using OddFrames
using StreamFrames
#== Proposed code is somewhat future, but will still not be as far off as one
might think.
==#
import Base: *
# using ToolipsUDP

tick_rate::Float64 = .05

mutable struct VultaTensor{D <: Number} <: AbstractTensor
    gen::Function
    vec::Vector{D}
    VultaVector(n::Number = 1) = new{Symbol(typeof(n)}([n for n in 1:n])
    VultaVector(f::Function, n::)
    VultaVector()
end

Ray(x::Int64)
StreamRay(x::Int64)

render!(c::Connection, v::VultaTensor) do cm::ComponentModifier

end

*(v::VultaVector, i::Vector{Int64}) = VultaVector.vec =
length(vv::VultaVector{<:Any}) = length(vv.vec)
vector() = VultaVector(1)
vector2() = VultaVector(2)
vector3() = VultaVector(3)
vector4() = VultaVector(4)
vulta_vector() = VultaVector(6)

vulta_window(title::String =)::Function = begin
    vulta_title::Component{:title} = title("vulta-title", )
    vulta_body::Component{:body} = body("vulta-root")
    push!(vulta_body, vulta_title)
    vulta_body::Component{:body}
end

mass(name::String, x::Int64, y::Int64, z::Int64)::Function = Component(name, "vultamass")

exert!(cm, name::String, towards::Vector{:3})

mutable struct VultaConnection{} <: Toolips.AbstractConnection
    game::Toolips.Route
    peersessions::Any
end

vulta_node!(v::VultaConnection)::Function = begin

end

function vulta_server(f::Function, )

end

# welcome to your new toolips project!
"""
home(c::Connection) -> _
--------------------
The home function is served as a route inside of your server by default. To
    change this, view the start method below.
"""
demo(c::Connection)
    write!(c, p("helloworld", text = "hello world!"))
end

routes = [route("/", home), fourofour]
extensions = Vector{ServerExtension}([Logger(), Files(), Session(), ])
"""
start(IP::String, PORT::Integer, ) -> ::ToolipsServer
--------------------
The start function starts the WebServer.
"""
function start(IP::String = "127.0.0.1", PORT::Integer = 8000)
     ws = WebServer(IP, PORT, routes = routes, extensions = extensions)
     ws.start(); ws
end
end # - module
