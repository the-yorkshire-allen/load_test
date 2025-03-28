# A function to generate random strings based on a seed
Puppet::Functions.create_function(:'load_test::rand_string') do
  # Generate a random string of specified length using optional charset
  # @param length The length of the random string to generate
  # @param seed A seed string to ensure consistent randomization
  # @param charset Optional character set to use (defaults to alphanumeric)
  # @return [String] A random string
  dispatch :rand_string do
    param 'Integer', :length
    param 'String', :seed
    optional_param 'String', :charset
    return_type 'String'
  end

  def rand_string(length, seed, charset = nil)
    # Default charset if none provided
    charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789' if charset.nil? || charset.empty?

    # Generate string by picking random characters
    result = ''
    length.times do |i|
      index = Puppet::Util.deterministic_rand("#{seed}_#{i}", charset.length).to_i
      result += charset[index]
    end

    result
  end
end
