##
# The class collects algorithms that is used in the program
#
class Algorithms
  ##
  # Algorithm to calculate how simular two strings are to each other
  # The result gets normalized to a value between 0 and 1 where
  # 1 means a perfect match.
  #
  # The method is used to help the user find typos when the error
  # VariableNotDefined occurs.
  def Algorithms.levenshtein_distance(identifier, other)
    m, n = identifier.length, other.length
    return 1 if m.zero? && n.zero?
    return 0 if m.zero? || n.zero?
    
    d = Array.new(m + 1) {
      Array.new(n + 1)
    }

    (0..m).each { |i|
      d[i][0] = i

    }
    (0..n).each { |j|
      d[0][j] = j
    }

    (1..m).each { |i|
      (1..n).each { |j|
        if identifier[i - 1] == other[j - 1]
          cost = 0
        else
          cost = 1
        end
        
        d[i][j] = [d[i - 1][j] + 1,
                   d[i][j - 1] + 1,
                   d[i - 1][j - 1] + cost 
                  ].min
      }
    }

    return 1.0 - d[m][n].to_f / [m, n].max
  end
end
