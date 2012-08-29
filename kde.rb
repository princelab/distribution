# Reimplemented from http://www-etud.iro.umontreal.ca/~botev/kde.R



# One dimensional KDE estimator which does not use the Gaussian assuming rule 
# of thumb for bandwidth determination.
# @input data [Array] # Vector of input data to base KD upon
# n [Integer] number of mesh points? (DEFAULT: n=2^12), n; n==2^m true
# min [Integer] Minimum value for output range
# max [Integer] Max value for output range
# @output [Array] 2D arrays, [mesh, density_value]
def kde(data_arr, n=nil, min=nil, max=nil) 
  # Initiate values 
  mesh_num = n.nil? ? 2**14 : 2**(Math.log(n,2).ceil)
  max ||= data_arr.each.max 
  min ||= data_arr.each.min 
  data_range = max-min
  Min = min-data_range/10
  Max = max+data_range/10
  data_num = data.size

  # Set up the grid for the estimation 
  grid_range = Max-Min
  dx = grid_range/mesh_num
  x_mesh = (Min..Max).step(dx)
  number_uniq = data.uniq.size
  # WRITE THE hist() fxn to return counts
  # normalize counts by total number, and then by the sum of the values of all the normalized values... 
  w = hist(data, x_mesh)
  initial_data = w / number_uniq.to_f
  initial_data = initial_data / initial_data.inject(:+)
end



