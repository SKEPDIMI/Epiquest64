require_relative "../npcs/city/Snapper"

class NPCs
  def initialize(controller)
    @@npcs = {
      '_SNAPPER' => Snapper.new(controller),
    }
    @controller = controller
  end

  def get(id)
    return @@npcs[id]
  end
end