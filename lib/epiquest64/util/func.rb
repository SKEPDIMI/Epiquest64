class Func
  def generate_luck
    n = rand(100)
    return n >= 50 ? -1 : n >= 40 ? 0 : n >= 30 ? 1 : n >= 20 ? 2 : n >= 5 ? 3 : n >= 1 ? 4 : 5
  end

  def to_readable_money(money)
    copper = money % 100
    silver = money / 100 % 100
    gold = money / 10000 % 10
    platinum = money / 100000

    res = "#{copper} copper"

    if gold > 0 then
      res = "#{gold} gold " + res
    end
    if platinum > 0 then
      res = "#{platinum} platinum " + res
    end

    return res
  end
end
