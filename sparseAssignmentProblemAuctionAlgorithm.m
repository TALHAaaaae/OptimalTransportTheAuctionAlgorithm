function [assignments, P, prices] = ...
	sparseAssignmentProblemAuctionAlgorithm(A, epsilon, ...
	epsilonDecreaseFactor, verbosity)

	N = size(A,1);

	if ( any(A(:)<0) )
		error('Only non-negative benefits allowed!');
	end

	if ( ~issparse(A) )
		warning('Converting A to sparse matrix!');
		A = sparse(A);
	end

	% heuristic for setting epsilon
	A = A*(N+1);
	maxAbsA = full(max(abs(A(:))));
	if ( ~exist('epsilon', 'var') || isempty(epsilon) )
		epsilon = max(maxAbsA/50, 1);
% 		epsilon = 0.5*((N*maxAbsA)/5 + N*maxAbsA); % see page 260 in [1]
	end

	if ( ~exist('epsilonDecreaseFactor', 'var') || isempty(epsilonDecreaseFactor) )
		epsilonDecreaseFactor = 0.2;
	end
	
	if ( ~exist('verbosity', 'var') )
		verbosity = 0;
	end
	
	[assignments, prices] = ...
		auctionAlgorithmSparseMex(A', epsilon, epsilonDecreaseFactor, ...
		maxAbsA, verbosity);
	
	if ( all(assignments<0) )
		warning('No feasible solution exists');
	end
	if ( nargout > 1 )
		linIdx = sub2ind(size(A),1:N,assignments');
		P = sparse(N,N);
		P(linIdx) = 1;
	end
end


function test()
%% DEMO
	% compile mex file
	mex -largeArrayDims auctionAlgorithmSparseMex.cpp -lut
	
	% create sample data
	N = 2000;
	
	A = rand(N,N);
	
	% create sparse matrix, since the mex implementation uses the Matlab
	% sparse matrix data structure
	A = sparse(A);

	% scale A such that round(Ascaled) has sufficient accuracy
	scalingFactor = 10^6;
	Ascaled = A*scalingFactor;
	
	% solve assignment problem
	tic
	[assignments,P] = sparseAssignmentProblemAuctionAlgorithm(Ascaled);
	toc
end
