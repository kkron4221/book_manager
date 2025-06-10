defmodule BookManager.Books.BookCoverUploader do
  @upload_dir "priv/static/uploads/book_covers"
  @web_path "/uploads/book_covers"

  def upload_cover(book_id, file) do
    # Create directory if it doesn't exist
    File.mkdir_p!(@upload_dir)

    # Generate a unique filename
    extension = Path.extname(file.filename)
    filename = "#{book_id}_#{:rand.uniform(10000)}#{extension}"
    filepath = Path.join(@upload_dir, filename)

    # Copy the uploaded file
    File.cp!(file.path, filepath)

    # Return the web path to the file
    {:ok, Path.join(@web_path, filename)}
  end

  def delete_cover(cover_url) when is_binary(cover_url) do
    if String.starts_with?(cover_url, @web_path) do
      filepath = Path.join("priv/static", String.replace(cover_url, @web_path, "uploads/book_covers"))
      File.rm(filepath)
    end
  end

  def delete_cover(_), do: :ok
end
