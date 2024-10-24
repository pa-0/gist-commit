import argparse
import os
import time
import exifread  # https://pypi.org/project/ExifRead/
import ffmpeg    # https://pypi.org/project/python-ffmpeg/


def is_picture(file):
    ''' Returns True if the file is an image. '''
    extension = os.path.splitext(file)[1]
    return extension.lower() in (".jpg", ".jpeg", ".gif", ".png")


def is_video(file):
    ''' Returns True if the file is a video. '''
    extension = os.path.splitext(file)[1]
    return extension.lower() in (".3gp", ".mov", ".mp4")


def get_date_modified(filepath):
    ''' Gets the OS modification date of the file. '''
    modification_time = os.path.getmtime(filepath)
    return time.gmtime(modification_time)


def get_exif_date_taken(filepath):
    ''' Gets the EXIF Date Taken of the file. '''
    try:
        file_handle = open(filepath, "rb")
        tags = exifread.process_file(
            file_handle, stop_tag="EXIF DateTimeOriginal")
        date_info = tags["EXIF DateTimeOriginal"].values
        datetime = time.strptime(date_info, '%Y:%m:%d %H:%M:%S')
        return datetime
    except KeyError:
        return None


def get_video_date_encoded(filepath):
    date_info = ffmpeg.probe(filepath)['streams'][0]['tags']['creation_time']
    datetime = time.strptime(date_info, '%Y-%m-%dT%H:%M:%S.%f%z')
    return datetime


def get_date_auto(file):
    ''' Gets the EXIF Date Taken if it exists, or the modification date otherwise. '''
    # First, try EXIF date taken
    date = get_exif_date_taken(file)
    if date is None:
        # try video
        date = get_video_date_encoded(file)
        if date is None:
            # If it didn't work, use date modified
            date = get_date_modified(file)
    return date


def handle_file(file, args):
    ''' Sorts a file into the correct folder. Creates the folder if it doesn't exist. '''

    # Figure out folder name
    modes = {
        'exif': get_exif_date_taken,
        'modified': get_date_modified,
        'auto': get_date_auto
    }
    get_date = modes[args.mode]
    file_date = get_date(file)

    if file_date is None:
        print("Skipped " + file)
        return

    directory_name = time.strftime(args.format, file_date)

    # Create folder if it does not exist
    if os.path.exists(directory_name) is False:
        if not args.test:
            os.mkdir(directory_name)
        print("Folder " + directory_name + " created.")

    # Move image to directory
    final_path = os.path.join(directory_name, file)
    print("Moving " + file + " to " + directory_name)

    # If in test mode, don't actually move file
    if os.path.exists(final_path) is False:
        if args.test:
            return
        os.rename(file, final_path)
    else:
        print("Skipped " + file + ", already exists in " + directory_name)


def main():
    ''' Organize files in the current folder into sub-folders '''

    parser = argparse.ArgumentParser(
        description="Organize pictures and videos into folders by date, "
        "in the format yyyy-mm-dd (customizable)")
    parser.add_argument(
        "target",
        help="directory (all files) or individual file")
    parser.add_argument(
        "-f", "--format", default="%Y-%m-%d",
        help="custom format for folder names, passed into time.strftime(). "
        "Default is %%Y-%%m-%%d. "
        "See https://docs.python.org/3/library/time.html#time.strftime")
    parser.add_argument(
        "-t", "--test", action="store_true",
        help="run in test mode, without actually moving the files")
    parser.add_argument(
        "-m", "--mode", choices=['auto', 'exif', 'modified'], default='auto',
        help="mode of reading the files' dates: exif for EXIF Date Taken (default), "
        "modified for file modification date, "
        "auto will use EXIF if possible, and the modification date otherwise")

    args = parser.parse_args()

    if (os.path.isdir(args.target)):
        for file in os.listdir('.'):
            if is_picture(file) or is_video(file):
                if os.path.isdir(file) is False:
                    handle_file(file, args)
    elif (os.path.isfile(args.target)):
        if is_picture(args.target) or is_video(args.target):
            handle_file(args.target, args)


if __name__ == "__main__":
    main()
