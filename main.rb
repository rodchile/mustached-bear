class AwesomeDataCreator
  attr_accessor :data, :account_last_id, :transaction_last_id, :usernames
  USERS = 20007
  
  
  def initialize
    @data = []
    @usernames = {}
    @account_last_id = 1
    @transaction_last_id = 1
  end

  def create_user_query(hash_values)
    "INSERT INTO USER_INFO (ID, USERNAME, PASSWORD, NOMBRE, APELLIDO, ROLE, FIRST_LOGIN, SERVICE_ID, SECURITY) VALUES ('#{hash_values[:id]}', '#{hash_values[:username]}', '#{hash_values[:password]}', '#{hash_values[:nombre]}', '#{hash_values[:apellido]}', '01', 'false', '01', '750');"
  end
  
  def create_account_query(acct_id)
    "INSERT INTO BALANCES (ACCOUNT_ID, ACCOUNT_TYPE,DESCRIPTION, ACCOUNT_NUMBER, CURRENCY, BANK_NAME, INIT_AMOUNT, NICKNAME, AVAILABLE, LEDGER, CREDIT_LIMIT, PAYOFF_AMOUNT) VALUES ('#{acct_id}', '01', 'CUENTA CORRIENTE #{acct_id}', '015002606', 'USD', 'defaultBank', '0.00', '', '585001.59', '628072.52', NULL, NULL);"
  end
  
  def create_transaction_query(transaction_id,account_id)
    "INSERT INTO TRANSACTIONS (TRX_ID,ACCOUNT_ID,INTERNAL_TRX,TRX_DATE,TRX_EFF_DATE,AMT,AMT_TYPE,NEW_ACCT_BAL,DESCRIPTION,BRANCH_ID) VALUES (#{transaction_id}, '#{account_id}', '0', '2012-05-09 23:59:58', '2012-05-10 00:00:01', 25.15, 'C', 80.1, 'Deposito de efectivo - suc.9', '0');"
  end
  
  def create_user_account_query(username,account_id)
    "insert into USER_SUMMARY(USERNAME,ACCOUNT_ID) values ('#{username}','#{account_id}');"
  end
  
  def create_user_account(accounts,username)
    rows = []
    accounts.each do |account|
      rows << create_user_account_query(username,account[:acct_id])
    end
    rows
  end
  
  def create_transactions(howManyTransactions,acct_id)
    transactions = []
    howManyTransactions.times do |number|
      transactions << create_transaction_query(transaction_last_id,acct_id)
      @transaction_last_id += 1
    end
    transactions
  end
  
  def create_accounts(howManyAccounts)
    accounts = []
    howManyAccounts.times do |number|
      account = {}
      account[:acct_id] = @account_last_id
      account[:acct_query] = create_account_query(@account_last_id)
      account[:transactions_query] = create_transactions(15,@account_last_id)
      accounts << account
      @account_last_id += 1
    end
    accounts
  end
  
  def create_user(number)
    user_values = {}
    user_values[:id] = "sim-" + number.to_s()
    user_values[:username] = "sim-" + number.to_s()
    user_values[:password] = "cohelo"
    user_values[:nombre] = "Pablo"
    user_values[:apellido] = "Mauricio"
    create_user_query user_values
  end
  
  def export_file()
    sql_file = File.new("users.sql","w+")
    #sql_file = File.open("users.sql")
    sql_file.puts("#Data simulationFile")
    data.each do |user|
      sql_file.puts("#Data for the user #{user[:username]}")
      sql_file.puts(user[:user])
      #Accounts Iterator
        user[:accounts].each do |account|
          sql_file.puts("#Data for the account #{account[:acct_id]}")
          sql_file.puts(account[:acct_query])
          #Transactions Iterator
          sql_file.puts("#Transactions for the account #{account[:acct_id]}")
          account[:transactions_query].each do |transaction|
            sql_file.puts(transaction)
          end
        end
        
        #Cross Product Iterator
        sql_file.puts("#Establishing relationship between user #{user[:username]} and their products.")
        user[:myproducts].each do |myproduct|
          sql_file.puts(myproduct)
        end
    end
  end
  
  def export_usernames()
    filename = ""
    user_file = nil
    @usernames.each do |key, value|
      if !filename.eql?(key)
        user_file = File.new(key.to_s() + ".sql","w+")
      end
      user_file.puts(value)
    end
  end
  
  def export_usernames_random()
    usernames_array = []
    @usernames.each do |key, value|
      usernames_array << value
    end
    
    1000.times do 
      usernames_array.sort_by{rand}
    end
    
    user_file = File.new(USERS.to_s() + "-random.sql","w+")    
    usernames_array.each do |value|
      user_file.puts(value)
    end
  end
  
  def load_users
    factor = USERS*0.5
    accounts_factor = 3
    
    reference_usernames = []
    
    USERS.times do |number|

      if number >= factor
        puts factor
        @usernames[factor] = reference_usernames
        reference_usernames = []
        factor += USERS*0.25        
        accounts_factor +=2
      end

      user_data = {}
      user_data[:username] = "sim-" + number.to_s()
      user_data[:user] = self.create_user(number)
      user_data[:accounts] = self.create_accounts(accounts_factor)
      user_data[:myproducts] = self.create_user_account(user_data[:accounts],user_data[:username])
      data << user_data
      reference_usernames << user_data[:username]
    end
    @usernames[factor] = reference_usernames
  end
end

myFooObject = AwesomeDataCreator.new
myFooObject.load_users
myFooObject.export_file()
myFooObject.export_usernames()
myFooObject.export_usernames_random()