module Func_model
  def generate_luck
    n = rand(100)
    
    return n >= 50 ? -1 : n >= 40 ? 0 : n >= 30 ? 1 : n >= 20 ? 2 : n >= 5 ? 3 : n >= 1 ? 4 : 5
  end
end