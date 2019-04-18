require "./ecdsa"

(1..25).each do |i|
  bits = i * 10
  d = (0x1 << (bits - 1)) | 0xFF

  total = 0
  10.times.each do
    t1 = Time.now
    ECDSA::Key.new(d)
    t2 = Time.now

    u1, u2 = [t1, t2].map{|t| t.to_i * 1000000 + t.usec }
    total += (u2 - u1)
  end
  puts total / 10.0 / 1000.0
end
