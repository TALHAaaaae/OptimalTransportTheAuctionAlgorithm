 
 function [ assignment, iteration ] = distributed_auction(H, epsilon)

      %%%n>k
      %%%epsilon is small scaler value
      %%%assignment selects optimal row in each column
 
     [n,k]= size(H);    
     alpha= zeros(1,n);
     price_list= zeros(n,k);
     bidder_max= zeros(n,k);
     
 
 for i=1:k
    
   price= zeros(n,1);
   b= zeros(n,1);
   
   ST =sort(H(:,i), 'descend');
   price_object= ST(1)-ST(2);
   [~, argmax]= max(H(:,i));
   price(argmax)= price_object+rand*.001;
   price_list(:,i)= price;
   
   b(argmax)= i;
   bidder_max(:,i)=b; 
   
   alpha(i)= argmax;
    
 end

 
 
  iteration=0;
  
  price_list_previous= zeros(n,k);
  
  while 1
  
      
iteration=iteration+k;
  
 for agent=1:k
    
price_list_0=price_list(:,agent);
 
    if (agent==1)
        
     beta= H(:,agent);   
     price_list_t= price_list(:,agent+1);
     alpha_0= alpha(agent);
     bidd=bidder_max(:, agent);
     bidd_neighbour= bidder_max(:, agent+1);
     
   [ price_list_update, alpha_t, bidd_update ] = Auction(agent,  price_list_0, price_list_t, alpha_0, beta, bidd, bidd_neighbour, epsilon,n);
   
   
    price_list(:, agent)= price_list_update;
    alpha(agent)= alpha_t;
    bidder_max(:,agent)=bidd_update;

   
    elseif (agent==k)
        
     beta= H(:,agent);    
     price_list_t= price_list(:,agent-1);
     alpha_0= alpha(agent);
     bidd=bidder_max(:, agent);
     bidd_neighbour= bidder_max(:, agent-1);
     
    [  price_list_update, alpha_t, bidd_update ] = Auction(agent, price_list_0, price_list_t, alpha_0, beta, bidd,  bidd_neighbour,  epsilon,n);
    
    
    price_list(:, agent)= price_list_update;
    alpha(agent)= alpha_t;
    bidder_max(:,agent)=bidd_update;
    


     
    else
        
    beta= H(:,agent);  
    price_list_t= [price_list(:,agent-1) price_list(:,agent+1)];
    alpha_0= alpha(agent);
    bidd=bidder_max(:, agent);
    bidd_neighbour= [bidder_max(:, agent-1) bidder_max(:, agent+1)];
    
    
   [  price_list_update, alpha_t, bidd_update ] = Auction(agent,price_list_0, price_list_t, alpha_0, beta, bidd,  bidd_neighbour, epsilon,n);
   
   
   
   price_list(:, agent)= price_list_update;
   alpha(agent)= alpha_t;
   bidder_max(:,agent)=bidd_update;


    end
   
    
end  
  
 
 
 if(price_list_previous== price_list)
     
     break;
     
 end
 
 price_list_previous = price_list; 
 
  end
  
  assignment=alpha(alpha~=0);

 end
 
 
 
function [ price_list_update, alpha_t, bidd_update ] = Auction( agent, price_list_0, price_list_t, alpha_0, beta, bidd, bidd_neighbour, epsilon,n)
 
 price_list_update= zeros(n,1);
 bidd_max= zeros(n,1);
 
for j=1:n
       
  [argvalue, argmax]= max([price_list_0(j,:) price_list_t(j,:)]);
  price_list_update(j,:)= argvalue;
  
 
  bidd_acc=[bidd(j,:) bidd_neighbour(j,:)];
  bidd_max(j,:)= bidd_acc(argmax);
 
   
end

  if (price_list_0(alpha_0,:)<=price_list_update(alpha_0,:) && bidd_max(alpha_0,:)~=agent)
     
     
      [~, argmax]=max(beta-price_list_update);         
    
      alpha_t = argmax;
      bidd_max(argmax,:)= agent;
      
      bidd_update= bidd_max;
      
      price_sort= sort((beta-price_list_update),'descend');
      gamma= minus(price_sort(1,:), price_sort(2,:));  
      price_list_update(alpha_t,:)=  price_list_0(alpha_t,:)+gamma+epsilon;
       
 else
       
      alpha_t= alpha_0;
      
      bidd_update= bidd_max;
      
      
  end
  
end

