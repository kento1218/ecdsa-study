require "digest/sha2"
require "json"
require "./ecdsa"

def sign(privfile)
  d = File.read(privfile).to_i(16)
  key = ECDSA::Key.new(d)
  px, py = key.pub

  message = STDIN.read
  m = Digest::SHA256.hexdigest(message).to_i(16)
  r, s = key.sign(m)

  data = {
    message: message,
    px: px, py: py,
    r: r, s: s
  }
  puts data.to_json
end

def verify
  data = JSON.parse(STDIN.read)
  m = Digest::SHA256.hexdigest(data["message"]).to_i(16)
  puts ECDSA.verify(m, data["px"], data["py"], data["r"], data["s"])
end

cmd = ARGV.shift
case (cmd)
when "sig" then
  sign(ARGV.shift)
when "ver" then
  verify
else
  STDERR.puts "Usage: ./main.rb [sig|ver] [private key file]"
end
