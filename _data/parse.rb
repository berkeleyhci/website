require "yaml"
require "CSV"
require "pp"

class ClassList
  attr_reader :header, :list
  def initialize(csv)
    csv_list = CSV.read csv # first row is header
    @header = csv_list.shift.map {|h| h.gsub " ", "" }
    @list = csv_list
  end

  def generate
    @list
      .map {|f| filterDate f  }
      .reject {|f| f["Class"].nil? }
      .map { |f| parseDate f  }
      .map { |f| parseRead f  }
  end

  private
  def filterDate(fields)
    Hash[fields
      .each_with_index
      .map { |c, i| c.nil?? nil : [@header[i], c.strip] }
      .reject {|hc| hc.nil? || hc[1] =~ /^\s*$/ || hc[1] == " "}
    ]
  end

  def parseDate(d)
    d["Date"] = "2017 " + d["Date"].split("-").reverse.join(" ")
    return d
  end

  def parseRead(d)
    return d if d["Reading"].nil?
    d["Reading"] = d["Reading"].split("\n").map { |r|
      {
        "name" => r.split(",").first.strip,
        "link" => r.split(",").last.strip,
      }
    }.reject { |r| r.nil? || r.empty? }
    return d
  end
end

# zip csv header with processed result
cl = ClassList.new "./schedule.csv"
full = cl.generate
puts full.to_yaml
