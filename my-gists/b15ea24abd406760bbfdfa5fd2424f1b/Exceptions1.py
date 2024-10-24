def main():
    num = 10
    try:
        res = num / 0
        print(res)
    except ZeroDivisionError as e:
        print("==> Got Error")
        raise    # Raising Exception
    
    return None

if __name__ == "__main__":
    main()