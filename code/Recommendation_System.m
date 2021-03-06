%% Import data from text file.
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2013/11/25 02:16:23

%% Initialize variables.
delimiter = '\t';
filepath = 'E:\Fall 2013\Social Media Mining\Homework and Assignments\HW4\ml-100k\ml-100k\u.data';
numberOfneighbors=5;
TotalUsers=943;
TotalItems=1682;
userNumber=269;
itemNumber=127;

%% Format string for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filepath,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
UserID = dataArray{:, 1};
ItemID = dataArray{:, 2};
Rating = dataArray{:, 3};
TimeStamp = dataArray{:, 4};

%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;

%% Sort the given randomly arranged dataset according to Userid,ItemID combination in ascending order
B = sortrows(UserID,1);
C = horzcat(UserID,ItemID,Rating);
SortedData = sortrows(C,[1 2]);

%% Transform the sorted data to a 943 X 1682 matrix where rows represent the users and columns represent the items.
X=zeros(TotalUsers,TotalItems);
m=size(SortedData,1);
for rowindex = 1:m
    userid=SortedData(rowindex,1);
    itemid=SortedData(rowindex,2);
    rating=SortedData(rowindex,3);
    X(userid,itemid)=rating;
end

%% Clear temporary variables
clearvars B C UserID ItemID Rating Timestamp userid itemid rating m;

%% Find average rating of recieved by every item
itemAvgRatingMatrix=zeros(1,TotalItems);
for columnIndex=1: TotalItems
temp=mean(X(X(:,columnIndex)~=0,columnIndex));
itemAvgRatingMatrix(1,columnIndex)=temp;
end

%% Find average rating given by each user in the matrix
userAvgRatingMatrix=zeros(1,TotalUsers);
for rowIndex=1: TotalUsers  
temp=mean(X(rowIndex,X(rowIndex,:)~=0));
userAvgRatingMatrix(1,rowIndex)=temp;
end
%% Finding cosine similarity between all possible user pairs

userSimilarityMatrix=zeros(TotalUsers,TotalUsers);
U=X;
U(:,itemNumber) = [];
for index1=1:TotalUsers
    for index2=1:TotalUsers
    if(index1==index2)
        userSimilarityMatrix(index1,index2)=-1;
        break;
    end
    numerator = dot(U(index1,:),U(index2,:));
    denom1=norm(U(index1,:));
    denom2=norm(U(index2,:));
    userSimilarityMatrix(index1,index2)= numerator/(denom1*denom2);
    userSimilarityMatrix(index2,index1)=userSimilarityMatrix(index1,index2);
    end
end

%% Finding cosine similarity between all possible item pairs

itemSimilarityMatrix=zeros(TotalItems,TotalItems);

V=X;
V(userNumber,:) = [];
for index1=1:TotalItems
    for index2=1:TotalItems
    if(index1==index2)
        itemSimilarityMatrix(index1,index2)=-1;
        break;
    end
    numerator = dot(V(:,index1),V(:,index2));
    denom1=norm(V(:,index1));
    denom2=norm(V(:,index2));
    itemSimilarityMatrix(index1,index2)= numerator/(denom1*denom2);
    itemSimilarityMatrix(index2,index1)=itemSimilarityMatrix(index1,index2);
    end
end
%% Clear temporary variables
clearvars U V;
%% Finding itembased similarity
[V,I]=sort(itemSimilarityMatrix(itemNumber,:),'descend');
Numerator=0;
Denominator=0;
count=0;
length=size(I,2);
for k=1:length
  if(X(userNumber,I(1,k))==0)
    continue;  
  else
    neighborItemNumber=I(1,k);
    temporary_numerator=itemSimilarityMatrix(itemNumber,neighborItemNumber)*(X(userNumber,neighborItemNumber)-itemAvgRatingMatrix(1,neighborItemNumber));
    Numerator=Numerator+temporary_numerator;
    temporary_denominator=itemSimilarityMatrix(itemNumber,neighborItemNumber);
    Denominator=Denominator+temporary_denominator;
    count=count+1;
    if(count==numberOfneighbors)
        break;
    end
  end
end
if(Numerator==0 || Denominator==0)
    ItembasedCF=itemAvgRatingMatrix(1,itemNumber);
else
result= Numerator/Denominator;
ItembasedCF=itemAvgRatingMatrix(1,itemNumber)+result;
end
%disp(ItembasedCF);

%% Finding userbased similarity
[V,I]=sort(userSimilarityMatrix(userNumber,:),'descend');
Numerator=0;
Denominator=0;
count=0;
length=size(I,2);
for k=1:length
  if(X(I(1,k),itemNumber)==0)
    continue;  
  else
    neighborUserNumber=I(1,k);
    temporary_numerator=userSimilarityMatrix(userNumber,neighborUserNumber)*(X(neighborUserNumber,itemNumber)-userAvgRatingMatrix(1,neighborUserNumber));
    Numerator=Numerator+temporary_numerator;
    temporary_denominator=userSimilarityMatrix(userNumber,neighborUserNumber);
    Denominator=Denominator+temporary_denominator;
    count=count+1;
    if(count==numberOfneighbors)
        break;
    end
  end
end
if(Numerator==0 || Denominator==0)
    UserbasedCF=userAvgRatingMatrix(1,userNumber);
else
result= Numerator/Denominator;
UserbasedCF=userAvgRatingMatrix(1,userNumber)+result;
end;
%disp(UserbasedCF);


%% Display Results
c1='User Number :';
c2='Item Number :';
c3='Number of Neighbors:';
message=sprintf('%s %d %s %d %s %d',c1,userNumber,c2,itemNumber,c3,numberOfneighbors);
disp(message);

content = 'User based Collaborative Filtering using matrix X is=';   
message = sprintf('%s', content);
disp(message);
disp(UserbasedCF);

content = 'Item based Collaborative Filtering using matrix X is=';   
message = sprintf('%s', content);
disp(message);
disp(ItembasedCF);