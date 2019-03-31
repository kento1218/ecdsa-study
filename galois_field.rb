require "./util"

# 有限体 Z/nZ を表すクラス
class GaloisField

  class Element
    def initialize(gf, a)
      @gf = gf;
      @a = a % gf.n;
    end

    attr_reader :gf

    def +(elm)
      @gf.add(self, elm)
    end
    def -(elm)
      @gf.add(self, -elm);
    end
    def *(elm)
      @gf.mul(self, elm)
    end
    def /(elm)
      @gf.mul(self, elm.inv)
    end
    def -@
      @gf.element(-@a)
    end
    def inv
      @gf.inv(self)
    end

    def to_i
      @a
    end

    def ==(elm)
      @gf == elm.gf && @a == elm.to_i
    end
  end

  def initialize(n)
    @n = n
  end

  attr_reader :n

  def element(a)
    Element.new(self, a)
  end

  def ==(gf)
    gf.n == @n
  end

  def add(a, b)
    raise if a.gf != b.gf
    element(a.to_i + b.to_i)
  end
  def mul(a, b)
    raise if a.gf != b.gf
    element(a.to_i * b.to_i)
  end
  def inv(a)
    g, x, y = Util.egcd(a.to_i, @n)
    raise if g != 1
    element(x)
  end
end
