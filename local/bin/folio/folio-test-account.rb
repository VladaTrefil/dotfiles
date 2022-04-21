#!/usr/bin/env ruby

credential = "test@test.test"

unless Folio::Account.where(email: credential).present?
  Folio::Account.create!(email: credential, password:  credential,
                         first_name: "test", last_name: "test",
                         role: "superuser")

  print "Created Folio::Account\n"
else
  print "Folio::Account exists\n"
end

# ===============================================================================
# Squared: {{{

if defined? Squared
  unless AdminUser.where(email: credential).present?
    AdminUser.create!(email: credential, password: credential,
                      first_name: "test", last_name: "test",
                      role: "superuser")

    print "Created AdminUser\n"
  else
    print "AdminUser exists\n"
  end

  Zone.all.each do |zone|
    unless User.where(email: credential, zone_id: zone.id).present?
      User.create!(email: credential, password: credential,
                   first_name: "test", last_name: "test",
                   nickname: "superuser", zone: zone)

      print "Created User\n"
    else
      print "User exists\n"
    end
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# MMSpektrum: {{{

if defined? Mmspektrum
  unless Folio::User.where(email: credential).present?
    Folio::User.create!(email: credential, password: credential,
                      first_name: "test", last_name: "test")

    print "Created Folio::User\n"
  else
    print "Folio::User exists\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Redside: {{{

if defined? Redside
  unless Folio::User.where(email: credential).present?
    Folio::User.create!(email: credential, password: credential,
                      first_name: "test", last_name: "test")

    print "Created Folio::User\n"
  else
    print "Folio::User exists\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Infocz: {{{

if defined? Infocz
  unless Infocz::User.where(email: credential).present?
    Infocz::User.create!(email: credential, password: credential,
                         first_name: "test", last_name: "test")

    print "Created Infocz::User\n"
  else
    print "Infocz::User exists\n"
  end
end

# }}}
# ===============================================================================

# ===============================================================================
# Acbcz: {{{

if defined? Acb
  unless Acb::User.where(email: credential).present?
    Acb::User.create!(email: credential, password: credential,
                         first_name: "test", last_name: "test")

    print "Created Acb::User\n"
  else
    print "Acb::User exists\n"
  end
end

# }}}
# ===============================================================================
