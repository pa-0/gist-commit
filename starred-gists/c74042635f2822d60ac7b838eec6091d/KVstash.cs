// This is an implementation of "IStashy" that saves/loads your objects as Json, in files, in a subfolder named after the type of the Object.

public class FileStashy : IStashy<string>
{
	private readonly IHostingEnvironment _hostingEnvironment;

	public FileStashy(IHostingEnvironment hostingEnvironment)
	{
		_hostingEnvironment = hostingEnvironment;
	}

	public string GetNewId<T>()
	{
		return Guid.NewGuid().ToString();
	}

	public void Save<T>(T t, string id)
	{
		if (id == null) throw new ArgumentNullException("id", "id cannot be null");

		var jsonFileName = GetFilePath<T>(id);

		using (StreamWriter file = File.CreateText(jsonFileName))
		{
			var serializer = new JsonSerializer();
			serializer.Serialize(file, t);
		}
	}

	public T Load<T>(string id)
	{
		if (id == null)
		{
			return default(T);
		}

		var jsonFileName = GetFilePath<T>(id);
		return LoadByName<T>(jsonFileName);
	}

	private string GetFilePath<T>(string id)
	{
		var jsonFileName = Path.Combine(GetObjectPath<T>(), id.EncodeFileNameString().ToLowerInvariant() + ".json");
		EnsurePathExists(Path.GetDirectoryName(jsonFileName));

		return jsonFileName;
	}

	private string GetFilePath<T>()
	{
		var jsonFileName = GetObjectPath<T>();
		EnsurePathExists(Path.GetDirectoryName(jsonFileName));
		return jsonFileName;
	}

	public IEnumerable<T> LoadAll<T>()
	{
		var jsonFilePath = GetFilePath<T>();
		var all = new List<T>();

		foreach (var jsonFileName in Directory.EnumerateFiles(jsonFilePath))
		{
			all.Add(LoadByName<T>(jsonFileName));
		}

		return all;
	}

	public void Delete<T>(string id)
	{
		if (id == null) throw new ArgumentNullException("id", "id cannot be null");

		// NO Deleting!!! (I usually don't implement this....)
		throw new MethodAccessException();
	}

	private static T LoadByName<T>(string jsonFileName)
	{
		if (!File.Exists(jsonFileName))
		{
			return default(T);
		}

		using (StreamReader file = File.OpenText(jsonFileName))
		{
			var serializer = new JsonSerializer();
			return (T)serializer.Deserialize(file, typeof(T));
		}
	}

	private string GetObjectPath<T>()
	{
		var rootPath = _hostingEnvironment.WebRootPath;
		var parentPath = Directory.GetParent(rootPath).FullName;
		var objectPath = Path.Combine(parentPath, "DATA", typeof(T).ToString());
		return objectPath;
	}

	private static void EnsurePathExists(string path)
	{
		if (string.IsNullOrWhiteSpace(path))
		{
			throw new DirectoryNotFoundException("Specified path was empty");
		}

		if (!Directory.Exists(path))
		{
			Directory.CreateDirectory(path);
		}
	}
}


// Here's the IStashy Interface itself:
public interface IStashy<K>
{
	void Save<T>(T t, K id);
	T Load<T>(K id);
	IEnumerable<T> LoadAll<T>();
	void Delete<T>(K id);
	K GetNewId<T>();
}

// Ah I noticed that FileStashy depends on "EncodeFileNameString" which is in this static class of extension methods:
// (The code is quite old school, wow)

public static class FileStashyExtensions
{
	public static string EncodeFileNameString(this string self)
	{
		self = self.EncodeFileNameChar('[');

    foreach (var c in Path.GetInvalidFileNameChars())
		{
			self = self.EncodeFileNameChar(c);
		}
		return self;
	}

	public static string EncodeFileNameChar(this string self, char c)
	{
		return self.Replace(c.ToString(), "[" + ((int)c).ToString() + "]");
	}

  public static string DecodeFileNameChar(this string self, char c)
	{
		return self.Replace("[" + ((int)c).ToString() + "]", c.ToString());
	}

	public static string DecodeFileNameString(this string self)
	{
		foreach (var c in Path.GetInvalidFileNameChars())
		{
			self = self.DecodeFileNameChar(c);
		}

		return self.DecodeFileNameChar('[');
	}
}


