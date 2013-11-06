#!/usr/bin/env ruby
# encoding: utf-8
if ARGV.length == 1 then
	s = File.new(ARGV[0], "r")
else
	exit 1
end
vals = {}
transes = {}
places = {}
s.each { |line|
	m = /^([TP][^-\s]+)?\s*-(?:(\d+)-)?(>|°)\s*([TP][^-\s]+)/.match(line)
	next if m.nil? || m[4].nil? || m[4].length < 2
	if m[1].nil? then
		vals[m[4][1..-1]] = 0 if vals[m[4][1..-1]].nil?
		vals[m[4][1..-1]] += if m[2].nil? then 1 else m[2].to_i end
	else
		c = ""
		if m[3] == ">" then
			c = if m[2].nil? then "1" else m[2] end
		end
		d = m[4][1..-1]
		if m[1][0] == "T" then
			transes[m[1][1..-1]] = [] if transes[m[1][1..-1]].nil?
			transes[m[1][1..-1]] << c+"-"+d
		else
			places[m[1][1..-1]] = [] if places[m[1][1..-1]].nil?
			places[m[1][1..-1]] << d+"-"+c
		end
	end
}
s.close()
action = true
while action do
	action = false
	transes.each { |tk,tv|
		active = true
		places.each { |pk,pv|
			pv.each { |s|
				s = s.split("-")
				next if s[0] != tk
				if pk == "IN" then
					val = STDIN.getc
					vals[pk] = if val.nil? then 0 else val.ord end
				end
				active = false if s[1].nil? && !vals[pk].nil? && vals[pk] > 0
				active = false if !s[1].nil? && (vals[pk].nil? || vals[pk] < s[1].to_i)
				break unless active
			}
			break unless active
		}
		action = true if active
		next if !active
		places.each { |pk,pv|
			pv.each { |s|
				s = s.split("-")
				next if s[0] != tk
				vals[pk] -= s[1].to_i if !s[1].nil?
			}
		}
		tv.each { |s|
			s = s.split("-")
			if s[1] == "OUT" then
				print s[0].to_i.chr
			else
				vals[s[1]] = 0 if vals[s[1]].nil?
				vals[s[1]] += s[0].to_i
			end
		}
	}
end
