require_relative "baseutility"

##
# A built in Utility that provides algorithms.
class AlgoManager < BaseUtility

  ##
  # Sorts a list using the merge sort algorithm.
  def AlgoManager.mergesort(array, func, scope, position)
    array = array.convert_to_list(scope, position)
    if array.is_a?(Error) then return array end

    func = func.convert_to_function(scope, position)
    if func.is_a?(Error) then return func end

    array = array.value

    new_list = List.new
    result = merge_sort_helper(array, func, scope, position)
    if result.is_a?(Error) then return result end
    new_list.value = result
    return new_list
    
  end

  ##
  # Sorts a list using the bubblesort algorithm.
  def AlgoManager.bubblesort(array, func, scope, position)
    array = array.convert_to_list(scope, position)
    if array.is_a?(Error) then return array end

    func = func.convert_to_function(scope, position)
    if func.is_a?(Error) then return func end

    array = array.value
    
    n = array.length
    swapped = true

    while swapped
      swapped = false

      (n - 1).times do |i|
        condition = func.call([array[i + 1], array[i]], scope, position)
        if condition.is_a?(Error) then return condition end
        condition = condition.convert_to_boolean(scope, position)
        if condition.is_a?(Error) then return condition end
        if condition.value
          array[i], array[i + 1] = array[i + 1], array[i]
          swapped = true
        end
      end
    end

    new_list = List.new
    new_list.value = array
    return new_list
  end

  ##
  # Sorts a list using the quicksort algorithm.
  def AlgoManager.quicksort(array, func, scope, position)
    array = array.convert_to_list(scope, position)
    if array.is_a?(Error) then return array end

    func = func.convert_to_function(scope, position)
    if func.is_a?(Error) then return func end

    array = array.value

    result = quicksort_helper(array, func, scope, position)
    if result.is_a?(Error) then return result end
    new_list = List.new
    new_list.value = result
    return new_list
  end

  ##
  # Searches a target in a List object using the binary search algorithm.
  def AlgoManager.binary_search(array, target, scope, position)
    array = array.convert_to_list(scope, position)
    if array.is_a?(Error) then return array end
    array = array.value
    
    low = 0
    high = array.length - 1
    
    while low <= high
      mid = (low + high) / 2
      
      condition = array[mid].equals(target, scope, position)
      if condition.is_a?(Error) then return condition end
      condition = condition.convert_to_boolean(scope, position)
      if condition.is_a?(Error) then return condition end
      if condition.value
        return Number.new(mid + 1)
      end
      condition = array[mid].less_than(target, scope, position)
      if condition.is_a?(Error) then return condition end
      condition = condition.convert_to_boolean(scope, position)
      if condition.is_a?(Error) then return condition end
      if condition.value
        low = mid + 1
      else
        high = mid - 1
      end
    end
    
    return Null.new(nil)
  end

  ##
  # Filters a List depending on the function provided as parameter
  def AlgoManager.filter(array, func, scope, position)
    array = array.convert_to_list(scope, position)
    if array.is_a?(Error) then return array end

    func = func.convert_to_function(scope, position)
    if func.is_a?(Error) then return func end

    array = array.value
    new_array = Array.new

    array.each { |item|
      condition = func.call([item], scope, position)
      if condition.is_a?(Error) then return condition end
      condition = condition.convert_to_boolean(scope, position)
      if condition.is_a?(Error) then return condition end
      if condition.value then new_array << item end
    }

    new_list = List.new
    new_list.value = new_array
    return new_list
  end

  ##
  # Executes the function provided as parameter on every
  # element in the List object provided. Returns a new List.
  def AlgoManager.transform(array, func, scope, position)
    array = array.convert_to_list(scope, position)
    if array.is_a?(Error) then return array end

    func = func.convert_to_function(scope, position)
    if func.is_a?(Error) then return func end

    array = array.value
    new_array = Array.new

    array.each { |item|
      new_value = func.call([item], scope, position)
      if new_value.is_a?(Error) then return new_value end
      new_array << new_value
    }

    new_list = List.new
    new_list.value = new_array
    return new_list
  end

  private

  def AlgoManager.merge_sort_helper(array, func, scope, position)
    if array.size <= 1
      return array
    end

    mid = array.size / 2
    left = merge_sort_helper(array[0...mid], func, scope, position)
    if left.is_a?(Error) then return left end
    right = merge_sort_helper(array[mid..-1], func, scope, position)
    if right.is_a?(Error) then return right end

    result = []

    while !left.empty? && !right.empty?
      condition = func.call([left.first, right.first], scope, position)
      if condition.is_a?(Error) then return condition end
      condition = condition.convert_to_boolean(scope, position)
      if condition.is_a?(Error) then return condition end
      if condition.value
        result << left.shift
      else
        result << right.shift
      end
    end

    return result.concat(left).concat(right)    
  end

  def AlgoManager.quicksort_helper(array, func, scope, position)
    if array.length <= 1
      return array
    end

    pivot = array[0]

    left = []
    right = []

    (1..(array.length - 1)).each { |i|
      condition = func.call([array[i], pivot], scope, position)
      if condition.is_a?(Error) then return condition end
      condition = condition.convert_to_boolean(scope, position)
      if condition.is_a?(Error) then return condition end
      if condition.value
        left << array[i]
      else
        right << array[i]
      end
    }

    return quicksort_helper(left, func, scope, position) + [pivot] + quicksort_helper(right, func, scope, position)
  end
end
