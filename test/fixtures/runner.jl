#!/usr/bin/env julia

import JSON

"""
    gen( x, name )

Generate fixture data and write to file.

# Arguments

* `x`: domain
* `name::AbstractString`: output filename

# Examples

``` julia
julia> x = linspace( 1e-36, 1e-38, 1007 );
julia> gen( x, \"data.json\" );
```
"""
function gen( x, name )
	y = Array( Any, length(x) );
	for i in eachindex(x)
		y[ i ] = bits( x[i] );
	end

	# Store data to be written to file as a collection:
	data = Dict([
		("x", x),
		("expected", y)
	]);

	# Based on the script directory, create an output filepath:
	filepath = joinpath( dir, name );

	# Write the data to the output filepath as JSON:
	outfile = open( filepath, "w" );
	write( outfile, JSON.json(data) );
	close( outfile );
end

# Get the filename:
file = @__FILE__;

# Extract the directory in which this file resides:
dir = dirname( file );

# Small values:
x = linspace( 1e-36, 1e-38, 1007 );
gen( x, "data.json" );
