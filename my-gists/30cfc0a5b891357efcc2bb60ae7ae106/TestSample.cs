using System;
using Xunit;

namespace IntegrationTests
{
   public class LoadingTests : IDisposable
   {
      private readonly RegFreeComActivationContext _regFreeComActivationContext = new RegFreeComActivationContext();
      
      [StaFact] // You need to install package Xunit.StaFact
      public void AppLoads()
      {
         Assert.True(AppLoader.Load()); // your app-specific logic
      }

      public void Dispose()
      {
         AppLoader.Shutdown(); // your app-specific logic
         _regFreeComActivationContext.Dispose();
      }
   }
}
