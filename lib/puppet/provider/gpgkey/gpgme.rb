Puppet::Type.type(:gpgkey).provide(:gpgme) do
  require 'gpgme'
  def exists?
    ! GPGME::Key.find(:secret, @resource[:name]).empty?
  end

  def self.instances
    GPGME::Key.find(:secret).collect do |key|
      new(:name => key.name)
    end
  end

  def create
    ctx = GPGME::Ctx.new
    keydata = "<GnupgKeyParms format=\"internal\">\n"
    keydata += "Key-Type: "       +@resource[:keytype]+"\n"
    keydata += "Key-Length: "     +@resource[:keylength]+"\n"
    keydata += "Subkey-Type: "    +@resource[:subkeytype]+"\n"
    keydata += "Subkey-Length: "  +@resource[:subkeylength]+"\n"
    keydata += "Name-Real: "      +@resource[:name]+"\n"
    keydata += "Name-Comment: "   +@resource[:comment]+"\n"
    keydata += "Name-Email: "     +@resource[:email]+"\n"
    keydata += "Expire-Date: "    +@resource[:expire]+"\n"
    keydata += "Passphrase: "     +@resource[:password]+"\n" unless @resource[:password].empty?
    keydata += "</GnupgKeyParms>\n"

    ctx.genkey(keydata, nil, nil)
  end

  def destroy
    GPGME::Key.find(:secret, @resource[:name]).each do |key|
      key.delete!(true)
    end
  end

end
