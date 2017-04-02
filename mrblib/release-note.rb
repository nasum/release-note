def __main__(argv)
  opts = Getopts.getopts(
    'r:t:f:v',
    'repository',
    'type',
    'issue',
    'pull-request',
    'version'
  )

  if opts.include?('v') || opts.include?('version')
    puts "release-note:#{ReleaseNote::VERSION}"
  else
    repo = opts['r'] || 'nasum/release-note'

    type = if opts.include?('issue')
      'issues'
    elsif opts.include?('pull-request')
      'pulls'
    else
      'issues'
    end

    from = opts['f'] || (Time.new - 60 * 60 * 24 * 7).strftime("%Y-%m-%dT%H:%M:%SZ")
    
    curl = Curl.new

    headers = {
      'User-Agent' => 'release-note'
    }

    url = "https://api.github.com/repos/#{repo}/#{type}?access_token=#{ENV['GITHUB_ACCESS_TOKEN']}&state=close&since=#{from}"
    response = curl.get(url, headers)

    JSON::parse(response.body).select{ |obj| obj['closed_at'] != nil }.each do |pr|
      doc = <<-"EOS"
#{pr['closed_at']}：#{pr['title']}
      EOS

      puts doc
    end
  end
end
