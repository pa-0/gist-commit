#include <iostream>
#include <string>
#include <chrono>
#include <thread>
#include <exception>
#include <cstdio>
using namespace std::chrono;

int timer(seconds); 
int stopwatch();
int showclock(bool repeat=false);
int help(std::string mesg="");
std::string humanreadabletime(double); 

std::string name("");

int main(int argc, char **argv) {
  name = argv[0];
  //parse options
  for(int i=1; i<argc; i++) {
    if (argv[i] == (std::string("-c"))) {
      if (argc > 2)
        return showclock(true);
      return showclock();
    } else if (argv[i] ==( std::string("-t"))){
      if (i+1 >= argc)
        return help("Invalid Options");
      std::string in(argv[i+1]);
      int colonc = 0;
      short colonp[in.length()];
      for(unsigned int j=0; j < in.length(); j++) {
        if (in[j] == ':') 
          colonp[colonc++] = j;
      }
      int times[colonc];
      try{
				times[0] = std::stoi(in.substr(0,colonp[0]));
      } 
      catch (std::exception e){
				return help("Invalid time input"); 
			}  
			for(int j=0; j < colonc; j++) {
				try{
        	times[j+1] = std::stoi(in.substr(colonp[j]+1, colonp[j+1]-colonp[j]-1));
      	} 
				catch(std::exception e){
    			return help("Invalid time input");
				}
			}
      unsigned long sum = times[colonc];
      for(int j=colonc-1; j >= 0; j--) {
        switch (colonc-j) {
          case 1: //minutes
            sum += times[j]*60;
            break;
          case 2: //hours
            sum += times[j]*60*60;
            break;
          case 3: //days
            sum += times[j]*60*60*24;
            break;
          case 4: //weeks
            sum += times[j]*60*60*24*7;
            break;
          case 5: //years
            sum += times[j]*60*60*24*365.25;
            break;
        }
      }
      if(sum == 0){
        std::cout<<"Little bastard, didn't put in a timer value, or put 0. "<< std::endl; 
        std::cout<<"Thought you could get away with it, didn't you."<<std::endl;
        std::cout<<"Well we found out. Now we are coming for you. With katanas. " <<std::endl; 
        std::cout<<"Our agent will be with you shortly" << std::endl; 
        return help("Idiot detected");
      }  
      return timer(seconds(sum));
    } else /*if (argv[i] == std::string("-h"))*/ {
      return help();
    }
  }
  return stopwatch();
}
int stopwatch() {
  auto t1 = high_resolution_clock::now();
  std::cout << "Time. Use Control-C to exit" <<std::endl;
  while(1 ){
  auto t2 = high_resolution_clock::now();
  std::cout << humanreadabletime((duration_cast<duration<double>>(t2-t1)).count())<< std::endl<<"\033[A\033[K";
  std::this_thread::sleep_for(milliseconds(100));
  }
  return 0;
}
int timer(seconds count) {
  auto t1 = high_resolution_clock::now();
  auto t2 = t1+count;
  while ( t2 > high_resolution_clock::now()) {
    std::cout << "Seconds Left:" <<
    std::endl <<
    duration_cast<duration<double>>(count-(high_resolution_clock::now()-t1)).count() << 
    std::endl << "\033[2A\033[K";
    std::this_thread::sleep_for(milliseconds(100));
  }
  std::cout << "Finished" << std::endl;
  return 0;
}
int showclock(bool repeat) {
  auto t1 = system_clock::to_time_t(system_clock::now());
  if (!repeat) {
    std::cout << ctime(&t1);
    return 0;
  }
  while(true) {
    t1 = system_clock::to_time_t(system_clock::now());
    std::cout << ctime(&t1)<<"\033[A\033[K";
    std::this_thread::sleep_for(seconds(1));
  }
}
int help(std::string mesg) {
  if (mesg.length() > 1)
    std::cout << "ERROR: " << mesg << std::endl;
  std::cout << "Usage:" << std::endl;
  std::cout << name << "           - act as a stopwatch, stoping when input is recieved" << std::endl;
  std::cout << name << " -c <loop> - displays the current date and time, optionally in a loop" << std::endl ;
  std::cout << name << " -t [[[[[years:]weeks:]days:]hours:]minutes:]<seconds> - wait for specified duration, then exit" << std::endl;
  return 1;
}
std::string humanreadabletime(double seconds){
  if ( seconds < 60 ) return std::to_string(seconds).std::string::append(""); 
  const int sec = (int) seconds;   
  std::string time = "";
  //same algorighm for sec --> min, min --> hour 
  int var = sec; 
  char maxConvert= 0;  
  //insert var%60 value into the string 
  time.std::string::insert(0, std::to_string(var%60) ); //Seconds 
  //make var the normal value again  
  var = (var - (var %60)) / 60; // seconds --> minutes  
  if ( var > 60){
    time.std::string::insert(0, std::to_string(var%60) + ":"); //minutes  
    var = (var - (var%60) ) / 60 ; // minutes --> hours 
  }
  else if(!maxConvert){ 
    time.std::string::insert(0, std::to_string(var) + ":"); // minutes  
    var = 0;  
    maxConvert=1; 
  }   
  //now for days 
  if(var > 24){
    time.std::string::insert(0, std::to_string(var%24) + ":" ); 
    var = (var - (var % 24) ) / 24; 
  }
  else if(!maxConvert){
    time.std::string::insert(0,std:: to_string(var) + ":" );
    maxConvert=1; 
  }
  // Its weird putting days in the : format, so they get to be special. 
  if( var > 365 ){ 
    time.std::string::insert(0, std::to_string(var%365) + " Days, " );
    var = (var - (var % 365) ) / 365; 
    time.std::string::insert(0,std::to_string(var) + " Years, ");  
  }
  else if(!maxConvert){
    time.std::string::insert(0, std::to_string(var) + "Days, "); 
  }
  std::string raw_ms = std::to_string(seconds-sec);
  raw_ms.std::string::erase(0,1);
  time.std::string::append(raw_ms);
  return time;    
}
