require "selfish"
require "selfish/core"

Selfish.lobby do
  _globals.add_slots(:bank_account  => _(),
                     :account       => _(),
                     :stock_account => _(),
                     :stock         => _())

  bank_account! _(:_parent  => traits.clonable,
                  :dollars  => 200,
                  :deposit  => method(:x) { dollars! dollars + x },
                  :withdraw => method(:x) { dollars! 0.max(dollars - x) })

  puts bank_account.dollars
  #=> 200
  puts (bank_account.deposit 50).dollars
  #=> 250
  puts (bank_account.withdraw 100).dollars
  #=> 150

  account! bank_account.copy
  puts (account.deposit 500).dollars
  #=> 650
  puts bank_account.dollars
  #=> 150

  stock_account! bank_account.copy
  stock_account.add_slots(:num_shares      => 10,
                          :price_per_share => 30,
                          :dollars  => method { num_shares * price_per_share },
                          :dollars! => method(:x) {
                            num_shares! x / price_per_share
                          })

  puts stock_account.dollars
  #=> 300
  puts (stock_account.dollars! 150).dollars
  #=> 150
  puts stock_account.num_shares
  #=> 5

  stock! stock_account.copy
  stock.dollars! 600
  puts stock.num_shares
  #=> 20
  puts (stock.deposit 60).dollars
  #=> 660
  puts stock.num_shares
  #=> 22
end
