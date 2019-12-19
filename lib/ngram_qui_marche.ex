defmodule NGram do
  defstruct n: 2, model: []

  @doc ~S"""
  ## Examples
  iex> NGram.build_from_string("The blue sky is near the red koala near the blue sky", 2)
  %NGram{
    model: %{
      ["<s>", "The"] => 1.0,
      ["The", "blue"] => 1.0,
      ["blue", "sky"] => 1.0,
      ["is", "near"] => 1.0,
      ["koala", "near"] => 1.0,
      ["near", "the"] => 1.0,
      ["red", "koala"] => 1.0,
      ["sky", "</s>"] => 0.5,
      ["sky", "is"] => 0.5,
      ["the", "blue"] => 0.5,
      ["the", "red"] => 0.5
    },
    n: 2
  }

  iex> NGram.build_from_string("The blue sky is near the red koala near the blue sky", 3)
  %NGram{
    model: %{
      ["<s>", "The", "blue"] => 1.0,
      ["The", "blue", "sky"] => 1.0,
      ["blue", "sky", "</s>"] => 0.5,
      ["blue", "sky", "is"] => 0.5,
      ["is", "near", "the"] => 1.0,
      ["koala", "near", "the"] => 1.0,
      ["near", "the", "blue"] => 0.5,
      ["near", "the", "red"] => 0.5,
      ["red", "koala", "near"] => 1.0,
      ["sky", "is", "near"] => 1.0,
      ["the", "blue", "sky"] => 1.0,
      ["the", "red", "koala"] => 1.0
    },
    n: 3
  }
  """
  def build_from_string(string, n) do
    tokens = String.split(string, " ") |> List.insert_at(0, "<s>") |> List.insert_at(-1, "</s>")
    model = tokens |> sliding_window(n) |> with_count() |> with_probability(n)
    %NGram{n: n, model: model}
  end

  def build_from_file(data_path, n) do
    model =
      data_path
      |> File.stream!()
      |> Stream.map(&String.replace(&1, "\n", ""))
      |> Stream.reject(&(&1 == ""))
      |> Stream.map(
        &(String.split(&1, " ")
          |> List.insert_at(0, "<s>")
          |> List.insert_at(-1, "</s>"))
      )
      |> Stream.map(&sliding_window(&1, n))
      |> Enum.flat_map(& &1)
      |> with_count()
      |> with_probability(n)

    ngram = %NGram{n: n, model: model}
    generate_lines(ngram, 10)
  end

  def random_word(ngram, last_word) do
    Enum.map(ngram.model, fn {window, _proba} -> window end)
    |> Enum.filter(fn window -> List.first(window) == last_word end)
    |> Enum.random()
    |> List.last()
  end

  def generate_word(ngram, line, last_word \\ " ") do
    case last_word do
      " " ->
        generate_word(ngram, line, random_word(ngram, "<s>"))

      "</s>" ->
        line

      _ ->
        line = line ++ [last_word]
        generate_word(ngram, line, random_word(ngram, last_word))
    end
  end

  def generate_line(ngram = %NGram{}) do
    line = []
    line = generate_word(ngram, line) |> Enum.join(" ")
    IO.inspect(line)
  end

  def generate_lines(ngram = %NGram{}, nb_lines) do
    for _ <- 1..nb_lines do
      generate_line(ngram)
    end
  end

  @doc ~S"""
  ## Examples
      iex> NGram.sliding_window([1, 2, 3, 4, 5, 6, 7], 5)
      [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6], [3, 4, 5, 6, 7]]

      iex> NGram.sliding_window([1, 2, 3, 4, 5, 6, 7], 2)
      [[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7]]

      iex> NGram.sliding_window([1, 2, 3, 4, 5, 6, 7], 1)
      [[1], [2], [3], [4], [5], [6], [7]]
  """
  def sliding_window(list, count) do
    Enum.chunk_every(list, count, 1, :discard)
  end

  defp with_count(windows) do
    windows
    |> Enum.group_by(& &1)
    |> map_values(&Enum.count(&1))
  end

  defp with_probability(windows_with_count, n) do
    # Create an index of sum of the "n - 1" previous elements to speed up process
    sum_index =
      windows_with_count
      |> Enum.group_by(fn {window, _count} -> Enum.take(window, n - 1) end)
      |> map_values(fn grouped_sub_windows ->
        grouped_sub_windows |> Enum.map(&elem(&1, 1)) |> Enum.sum()
      end)

    windows_with_count
    |> Enum.map(fn {window, count} ->
      {window, count / sum_index[Enum.take(window, n - 1)]}
    end)
    |> Map.new()
  end

  # Map values of a map, return the map with values cooked with `fun`
  defp map_values(map = %{}, fun) do
    map
    |> Enum.map(fn {key, value} ->
      {key, fun.(value)}
    end)
    |> Map.new()
  end
end
