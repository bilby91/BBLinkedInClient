#BBLinkedInClient

BBLinkedInClient is a small wrapper on top of LinkedIn API. It handles oauth authentication and exposes some clean methods for interacting with the API.


## Usage

Initialise an `BBLinkedInClient` with this custom initialiser.

```objective-c
BBLinkedInClient client = [[BBLinkedInClient alloc] initWithConsumerKey:@"1co3eakqdpi7" andSecret:@"Gfw9032owWo0ty0E"];
```

In any view controller present a BBLinkedInViewController like this:

```objective-c
BBLinkedInAuthViewController *bbViewController = [[LinkedInAuthViewController alloc] initWithClient:client scope:@"r_fullprofile r_emailaddress r_network rw_groups"];

bbViewController.delegate = self;
```

self should implement BBLinkedInAuthViewControllerDelegate.

```objective-c
- (void)succesfullAuthentication;

- (void)failedAuthenticationWithError:(NSError *)error;

- (void)authenticationCanceled;
```

After a successful authentication your client should have the access token correctly configured. 

You can now start interacting with the API like this.

```objective-c
[client getUserWithPublicProfileUrl:@"http://www.linkedin.com/in/bilby91" fields:@"(first-name,last-name)" successBlock:^(id response) {
        NSLog(@"%@",response);
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",error);
    }];
```

Read `BBLinkedInClient.h` and see all the available methods.


If you already have the access token of the user you can set it up manually instead of presenting the view controller.

```objective-c
BBLinkedInClient client = [[BBLinkedInAPI alloc] initWithAccessToken:access_token];
```
or
```objective-c
client.access_token = @"your_access_token";
```


## Contribution

Contributions are more than welcome! 

If you find any bug just submit a pull request. 

Thanks!

## License

Copyright (c) 2014 Martín Fernández  (http://bilby91.com/)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.