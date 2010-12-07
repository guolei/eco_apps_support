class Fixnum
  def to_formatted_time(with_second = true)
    h = self / 3600
    m = (self % 3600) / 60
    s = self % 60
    str = []
    str << (s < 10 ? "0#{s}" : s) if with_second
    str << (((h > 0 || !with_second) && m < 10) ? "0#{m}" : m)
    str << h if h > 0 or !with_second
    str.reverse.join(":")
  end

  def to_time_zone
    ActiveSupport::TimeZone.all.each do |tz|
      return tz if self == tz.utc_offset/3600
    end
  end
end