require "./galois_field"
require "./elliptic_curve"

Curve = EllipticCurve.new(
  GaloisField.new(0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF),
  0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC,
  0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B
)
G = Curve.point(
  0x6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296,
  0x4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5
)
N = 0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551

def main
  gf = GaloisField.new(N)

  priv = gf.element(rand(1...N))
  pub = G.scholar(priv)
  msg = gf.element(99999999)

  k = gf.element(rand(1...N))
  p0 = G.scholar(k)
  r = gf.element(p0.x.to_i)
  s = (msg + r * priv) / k

  puts "sign"
  puts "r: #{r.to_i}"
  puts "s: #{s.to_i}"


  w = s.inv
  u1 = msg * w
  u2 = r * w

  p1 = G.scholar(u1) + pub.scholar(u2)

  puts "verify: #{p1.x.to_i == r.to_i}"
end

main
